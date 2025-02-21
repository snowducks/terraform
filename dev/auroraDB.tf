resource "aws_rds_global_cluster" "dev_aurora_global_cluster" {
  global_cluster_identifier = "dev-aurora-global-cluster"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전
  database_name             = "example_db"
}

resource "aws_db_subnet_group" "dev_aurora_subnet_group" {
  name       = "dev-aurora-subnet-group"
  subnet_ids = module.dev_vpc.private_subnets  # VPC 모듈에서 서브넷 가져오기

  tags = {
    Name = "AuroraSubnetGroup"
  }
}

resource "aws_rds_cluster" "dev_aurora_primary_cluster" {

  engine                    = aws_rds_global_cluster.dev_aurora_global_cluster.engine
  engine_version            = aws_rds_global_cluster.dev_aurora_global_cluster.engine_version
  cluster_identifier        = "aurora-primary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.dev_aurora_global_cluster.id
  database_name             = "mydatabase"
  master_username           = var.db_master_username
  master_password           = var.db_master_password
  backup_retention_period   = 7
  preferred_backup_window   = "02:00-03:00"
  skip_final_snapshot       = true
  #storage_encrypted         = true
  apply_immediately         = true

  db_subnet_group_name      = aws_db_subnet_group.dev_aurora_subnet_group.name
  vpc_security_group_ids    = [module.dev_aurora_sg.security_group_id]  # 모듈에서 SG 가져오기

  tags = {
    Name = "AuroraPrimary"
  }
}

resource "aws_rds_cluster_instance" "dev_aurora_primary_instance" {
  count               = 1 
  identifier          = "aurora-primary-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.dev_aurora_primary_cluster.id
  instance_class      = "db.r5.large"  
  engine              = aws_rds_cluster.dev_aurora_primary_cluster.engine
  engine_version      = aws_rds_cluster.dev_aurora_primary_cluster.engine_version
  publicly_accessible = false 
  apply_immediately   = true
}


module "dev_aurora_sg" {
  source = "../modules/security_group"

  name   = "dev-aurora-sg"
  vpc_id = module.dev_vpc.vpc_id

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
output "dev_aurora_global_cluster_arn" {
  description = "ARN of the Aurora Global Cluster"
  value       = aws_rds_global_cluster.dev_aurora_global_cluster.arn
}

# RDS 클러스터의 엔드포인트 출력
output "aurora_cluster_endpoint" {
  description = "Endpoint of the Aurora Cluster"
  value       = aws_rds_cluster.dev_aurora_primary_cluster.endpoint
}

# RDS 클러스터의 Reader 엔드포인트 출력
output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora Cluster"
  value       = aws_rds_cluster.dev_aurora_primary_cluster.reader_endpoint
}

# RDS 클러스터의 보안 그룹 ID 출력
output "aurora_security_group_id" {
  description = "Security Group ID associated with the Aurora Cluster"
  value       = module.dev_aurora_sg.security_group_id
}

# RDS 클러스터의 서브넷 그룹 이름 출력
output "aurora_subnet_group_name" {
  description = "Subnet Group Name of the Aurora Cluster"
  value       = aws_db_subnet_group.dev_aurora_subnet_group.name
}

output "aurora_global_cluster_id" {
  description = "ID of the Aurora Global Cluster"
  value       = aws_rds_global_cluster.dev_aurora_global_cluster.id
}
