# 서브넷 그룹 생성
resource "aws_db_subnet_group" "dr_ecs_aurora_subnet_group" {
  name       = "dr-ecs-aurora-subnet-group"
  subnet_ids = module.dr_ecs_vpc.private_subnets  # VPC 서브넷 사용

  tags = {
    Name = "dr-ecs-aurora-subnet-group"
  }
}

data "terraform_remote_state" "aurora_primary_state" {
  backend = "s3"

  config = {
    bucket = "prod-snowduck-terraform-state"
    key = "prod/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}


# Aurora 보조 클러스터 생성 (EKS 연계)
resource "aws_rds_cluster" "dr_ecs_aurora_secondary" {
  cluster_identifier        = "dr-ecs-aurora-secondary-cluster"
  global_cluster_identifier  = data.terraform_remote_state.aurora_primary_state.outputs.aurora_global_cluster_id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전으로 변경
  db_subnet_group_name      = aws_db_subnet_group.dr_ecs_aurora_subnet_group.name
  vpc_security_group_ids    = [module.dr_ecs_aurora_sg.security_group_id]  # 보안 그룹 사용
  skip_final_snapshot       = true
  apply_immediately         = true

  tags = {
    Name = "dr-ecs-aurora-secondary-cluster"
  }
}

# Aurora 보조 클러스터 (EKS) - Read Replica 인스턴스 추가
resource "aws_rds_cluster_instance" "dr_ecs_aurora_secondary_reader" {
  count                = 2  # 읽기 전용 인스턴스 개수 (필요하면 조정 가능)
  identifier           = "dr-ecs-aurora-secondary-reader-${count.index}"
  cluster_identifier   = aws_rds_cluster.dr_ecs_aurora_secondary.id  # 보조 클러스터에 연결
  instance_class       = "db.r5.large"  # Aurora MySQL 인스턴스 유형
  engine              = "aurora-mysql"
  publicly_accessible  = false  # 외부 접근 불가
  apply_immediately    = true
}



# 보안 그룹 생성 (EKS 연계)
module "dr_ecs_aurora_sg" {
  source = "../modules/security_group"

  name   = "dr-ecs-aurora-sg"
  vpc_id = module.dr_ecs_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.2.0.0/16"]  # VPC 내부에서만 접근 가능하도록 설정
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}




# 🔹 Aurora DR 보조 클러스터 (EKS) 엔드포인트
output "dr_ecs_aurora_secondary_cluster_endpoint" {
  description = "Writer endpoint of the DR Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.dr_ecs_aurora_secondary.endpoint
}

output "dr_ecs_aurora_secondary_reader_endpoint" {
  description = "Reader endpoint of the DR Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.dr_ecs_aurora_secondary.reader_endpoint
}

# 🔹 Aurora DR Read Replica 인스턴스 ID 목록
output "dr_ecs_aurora_secondary_reader_instances" {
  description = "List of DR Aurora Secondary Read Replica Instances (EKS)"
  value       = aws_rds_cluster_instance.dr_ecs_aurora_secondary_reader[*].id
}

# 🔹 Aurora DR 보안 그룹 ID
output "dr_ecs_aurora_secondary_security_group_id" {
  description = "Security Group ID associated with the DR Aurora Secondary Cluster (EKS)"
  value       = module.dr_ecs_aurora_sg.security_group_id
}

# 🔹 Aurora DR 서브넷 그룹 이름
output "dr_ecs_aurora_secondary_subnet_group_name" {
  description = "Subnet Group Name of the DR Aurora Secondary Cluster (EKS)"
  value       = aws_db_subnet_group.dr_ecs_aurora_subnet_group.name
}

