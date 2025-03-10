# 서브넷 그룹 생성
resource "aws_db_subnet_group" "dr_ecs_aurora_subnet_group" {
  name       = "dr-ecs-aurora-subnet-group"
  subnet_ids = module.dr_ecs_vpc.private_subnets

  tags = {
    Name = "dr-ecs-aurora-subnet-group"
  }
}

# 기존 Aurora Primary 클러스터 정보 가져오기 (S3 백엔드에서 상태값 로드)
data "terraform_remote_state" "aurora_primary_state" {
  backend = "s3"

  config = {
    bucket = "prod-snowduck-terraform-state"
    key    = "prod/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# Aurora 보조 클러스터 생성 (EKS 연계)
resource "aws_rds_cluster" "dr_ecs_aurora_secondary" {
  cluster_identifier        = "dr-ecs-aurora-secondary-cluster"
  global_cluster_identifier = data.terraform_remote_state.aurora_primary_state.outputs.aurora_global_cluster_id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2" 
  db_subnet_group_name      = aws_db_subnet_group.dr_ecs_aurora_subnet_group.name
  vpc_security_group_ids    = [module.dr_ecs_aurora_sg.security_group_id]
  skip_final_snapshot       = true 
  apply_immediately         = true

  tags = {
    Name = "dr-ecs-aurora-secondary-cluster"
  }
}

# Aurora 보조 클러스터의 읽기 전용 인스턴스 생성 (EKS 연계)
resource "aws_rds_cluster_instance" "dr_ecs_aurora_secondary_reader" {
  count               = 2 
  identifier          = "dr-ecs-aurora-secondary-reader-${count.index}"
  cluster_identifier  = aws_rds_cluster.dr_ecs_aurora_secondary.id
  instance_class      = "db.r5.large"
  engine             = "aurora-mysql"
  publicly_accessible = false 
  apply_immediately   = true
}

# 보안 그룹 생성 (Aurora 보조 클러스터 전용)
module "dr_ecs_aurora_sg" {
  source = "../modules/security_group"

  name   = "dr-ecs-aurora-sg"
  vpc_id = module.dr_ecs_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.2.0.0/16"] 
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

output "dr_ecs_aurora_secondary_cluster_endpoint" {
  description = "DR Aurora 보조 클러스터 (EKS) Writer 엔드포인트"
  value       = aws_rds_cluster.dr_ecs_aurora_secondary.endpoint
}

output "dr_ecs_aurora_secondary_reader_endpoint" {
  description = "DR Aurora 보조 클러스터 (EKS) Reader 엔드포인트"
  value       = aws_rds_cluster.dr_ecs_aurora_secondary.reader_endpoint
}

output "dr_ecs_aurora_secondary_reader_instances" {
  description = "DR Aurora 보조 클러스터 (EKS) Read Replica 인스턴스 목록"
  value       = aws_rds_cluster_instance.dr_ecs_aurora_secondary_reader[*].id
}

output "dr_ecs_aurora_secondary_security_group_id" {
  description = "DR Aurora 보조 클러스터 (EKS) 보안 그룹 ID"
  value       = module.dr_ecs_aurora_sg.security_group_id
}

output "dr_ecs_aurora_secondary_subnet_group_name" {
  description = "DR Aurora 보조 클러스터 (EKS) 서브넷 그룹 이름"
  value       = aws_db_subnet_group.dr_ecs_aurora_subnet_group.name
}
