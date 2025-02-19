resource "aws_rds_global_cluster" "aurora_global" {
  global_cluster_identifier = "aurora-global-cluster"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전으로 변경
  database_name             = "example_db"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [module.vpc.private_subnets[2], module.vpc.private_subnets[4]]  # VPC 모듈에서 서브넷 가져오기

  tags = {
    Name = "AuroraSubnetGroup"
  }
}

resource "aws_rds_cluster" "aurora_primary" {

  engine                    = aws_rds_global_cluster.aurora_global.engine
  engine_version            = aws_rds_global_cluster.aurora_global.engine_version
  cluster_identifier        = "aurora-primary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.aurora_global.id
  database_name             = "mydatabase"
  master_username           = var.db_master_username
  master_password           = var.db_master_password
  backup_retention_period   = 7
  preferred_backup_window   = "02:00-03:00"
  skip_final_snapshot       = true
  #storage_encrypted         = true
  apply_immediately         = true

  db_subnet_group_name      = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids    = [module.aurora_sg.security_group_id]  # 모듈에서 SG 가져오기

  tags = {
    Name = "AuroraPrimary"
  }
}

module "aurora_sg" {
  source = "../modules/security_group"

  name   = "aurora-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]  # 내부 VPC에서만 접근 가능하도록 설정
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

# RDS 글로벌 클러스터의 ARN 출력
output "aurora_global_cluster_arn" {
  description = "ARN of the Aurora Global Cluster"
  value       = aws_rds_global_cluster.aurora_global.arn
}

# RDS 클러스터의 엔드포인트 출력
output "aurora_cluster_endpoint" {
  description = "Endpoint of the Aurora Cluster"
  value       = aws_rds_cluster.aurora_primary.endpoint
}

# RDS 클러스터의 Reader 엔드포인트 출력
output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora Cluster"
  value       = aws_rds_cluster.aurora_primary.reader_endpoint
}

# RDS 클러스터의 보안 그룹 ID 출력
output "aurora_security_group_id" {
  description = "Security Group ID associated with the Aurora Cluster"
  value       = module.aurora_sg.security_group_id
}

# RDS 클러스터의 서브넷 그룹 이름 출력
output "aurora_subnet_group_name" {
  description = "Subnet Group Name of the Aurora Cluster"
  value       = aws_db_subnet_group.aurora_subnet_group.name
}
