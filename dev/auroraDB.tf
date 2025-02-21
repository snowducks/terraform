resource "aws_db_subnet_group" "dev_aurora_subnet_group" {
  name       = "dev-aurora-subnet-group"
  subnet_ids = module.dev_vpc.private_subnets
  tags = {
    Name = "dev-aurora-subnet-group"
  }
}

data "terraform_remote_state" "prod_aurora_primary_state" {
  backend = "s3"
  config = {
    bucket = "prod-snowduck-terraform-state"
    key = "prod/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# Aurora 보조 클러스터 생성 (EKS 연계)
resource "aws_rds_cluster" "dev_aurora_secondary_cluster" {
  cluster_identifier        = "dev-aurora-secondary-cluster"
  global_cluster_identifier  = data.terraform_remote_state.prod_aurora_primary_state.outputs.aurora_global_cluster_id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전으로 변경
  db_subnet_group_name      = aws_db_subnet_group.dev_aurora_subnet_group.name
  vpc_security_group_ids    = [module.dev_aurora_sg.security_group_id]  # 보안 그룹 사용
  skip_final_snapshot       = true
  apply_immediately         = true
  tags = {
    Name = "dev-aurora-secondary-cluster"
  }
}

resource "aws_rds_cluster_instance" "dev_aurora_secondary_instance" {
  count                = 2  # 원하는 만큼 Reader Instance 개수를 조절
  identifier           = "dev-aurora-secondary-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.dev_aurora_secondary_cluster.id
  instance_class       = "db.r5.large"  # Aurora MySQL 지원 인스턴스 타입
  engine              = "aurora-mysql"
  publicly_accessible  = false
  apply_immediately    = true
  tags = {
    Name = "dev-aurora-secondary-instance-${count.index}"
  }
}

# 보안 그룹 생성 (EKS 연계)
module "dev_aurora_sg" {
  source = "../modules/security_group"
  name   = "dev-aurora-sg"
  vpc_id = module.dev_vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.1.0.0/16"]  # VPC 내부에서만 접근 가능하도록 설정
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

# Aurora 보조 클러스터 출력값
output "aurora_secondary_cluster_endpoint" {
  description = "Endpoint of the Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.dev_aurora_secondary_cluster.endpoint
}

output "aurora_secondary_reader_endpoint" {
  description = "Reader endpoint of the Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.dev_aurora_secondary_cluster.reader_endpoint
}

output "aurora_secondary_security_group_id_eks" {
  description = "Security Group ID associated with the Aurora Secondary Cluster (EKS)"
  value       = module.dev_aurora_sg.security_group_id
}

output "aurora_secondary_subnet_group_name_eks" {
  description = "Subnet Group Name of the Aurora Secondary Cluster (EKS)"
  value       = aws_db_subnet_group.dev_aurora_subnet_group.name
}