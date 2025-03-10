resource "aws_rds_global_cluster" "prod_aurora_global_cluster" {
  global_cluster_identifier = "aurora-global-cluster"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"
  database_name             = "example_db"
}

resource "aws_db_subnet_group" "prod_aurora_subnet_group" {
  name       = "prod-aurora-subnet-groups"
  subnet_ids = module.prod_vpc.private_subnets
}

resource "aws_rds_cluster" "aurora_primary" {
  engine                    = aws_rds_global_cluster.prod_aurora_global_cluster.engine
  engine_version            = aws_rds_global_cluster.prod_aurora_global_cluster.engine_version
  cluster_identifier        = "aurora-primary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.prod_aurora_global_cluster.id
  database_name             = "mydatabase"
  master_username           = var.db_master_username
  master_password           = var.db_master_password
  backup_retention_period   = 7
  preferred_backup_window   = "02:00-03:00"
  skip_final_snapshot       = true
  #storage_encrypted         = true
  apply_immediately         = true

  db_subnet_group_name      = aws_db_subnet_group.prod_aurora_subnet_group.name
  vpc_security_group_ids    = [module.prod_aurora_sg.security_group_id]

  tags = {
    Name = "AuroraPrimary"
  }
}

resource "aws_rds_cluster_instance" "prod_aurora_primary_instance" {
  count               = 1 
  identifier          = "prod-aurora-primary-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_primary.id
  instance_class      = "db.r5.large"  
  engine              = aws_rds_cluster.aurora_primary.engine
  engine_version      = aws_rds_cluster.aurora_primary.engine_version
  publicly_accessible = false 
  apply_immediately   = true
}



resource "aws_rds_cluster_instance" "prod_aurora_read_replica" {
  count               = 2
  identifier          = "prod-aurora-reader-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_primary.id
  instance_class      = "db.r5.large"
  engine              = aws_rds_cluster.aurora_primary.engine
  engine_version      = aws_rds_cluster.aurora_primary.engine_version
  publicly_accessible = false
  apply_immediately   = true
}


module "prod_aurora_sg" {
  source = "../modules/security_group"

  name   = "aurora-sg"
  vpc_id = module.prod_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.3.0.0/16"]
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

output "aurora_global_cluster_arn" {
  description = "prod 환경 Aurora 글로벌 클러스터 ARN"
  value       = aws_rds_global_cluster.prod_aurora_global_cluster.arn
}

output "aurora_cluster_endpoint" {
  description = "prod 환경 Aurora 클러스터 엔드포인트"
  value       = aws_rds_cluster.aurora_primary.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "prod 환경 Aurora 클러스터 Reader 엔드포인트"
  value       = aws_rds_cluster.aurora_primary.reader_endpoint
}

output "aurora_security_group_id" {
  description = "prod 환경 Aurora 클러스터에 연결된 보안 그룹 ID"
  value       = module.prod_aurora_sg.security_group_id
}

output "aurora_subnet_group_name" {
  description = "prod 환경 Aurora 클러스터 서브넷 그룹 이름"
  value       = aws_db_subnet_group.prod_aurora_subnet_group.name
}

output "aurora_global_cluster_id" {
  description = "prod 환경 Aurora 글로벌 클러스터 ID"
  value       = aws_rds_global_cluster.prod_aurora_global_cluster.id
}

output "aurora_read_instance_ids" {
  description = "prod 환경 Aurora Read Replica 인스턴스 목록"
  value       = aws_rds_cluster_instance.prod_aurora_read_replica[*].id
}