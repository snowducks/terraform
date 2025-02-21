# Aurora Subnet Group (기존 코드 유지)
resource "aws_db_subnet_group" "dev_aurora_subnet_group" {
  name       = "dev-aurora-subnet-group"
  subnet_ids = module.dev_vpc.private_subnets
  tags = {
    Name = "dev-aurora-subnet-group"
  }
}

# Dev 환경에서만 사용할 Aurora Cluster (Regional)
resource "aws_rds_cluster" "dev_aurora_cluster" {
  cluster_identifier     = "dev-aurora-cluster" 
  engine                = "aurora-mysql"
  engine_version        = "8.0.mysql_aurora.3.04.2"  
  database_name             = "mydatabase"
  master_username           = var.db_master_username
  master_password           = var.db_master_password
  db_subnet_group_name  = aws_db_subnet_group.dev_aurora_subnet_group.name
  vpc_security_group_ids = [module.dev_aurora_sg.security_group_id]
  
  backup_retention_period = 7  
  preferred_backup_window = "07:00-09:00"  

  storage_encrypted       = true 
  deletion_protection     = false  

  apply_immediately       = true
  skip_final_snapshot     = true  

  tags = {
    Name = "dev-aurora-cluster"
  }
}

# Aurora Cluster의 Writer 노드 (Primary Instance)
resource "aws_rds_cluster_instance" "dev_aurora_instance" {
  count                = 2  # ✅ 필요에 따라 Writer 1개 + Reader 1개 또는 다수 생성 가능
  identifier           = "dev-aurora-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.dev_aurora_cluster.id
  instance_class       = "db.r5.large"  
  engine              = "aurora-mysql"
  publicly_accessible  = false  
  apply_immediately    = true

  tags = {
    Name = "dev-aurora-instance-${count.index}"
  }
}

# Aurora 보안 그룹
module "dev_aurora_sg" {
  source = "../modules/security_group"
  name   = "dev-aurora-sg"
  vpc_id = module.dev_vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]  
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

# Aurora DB 엔드포인트 출력값
output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora Cluster (Dev)"
  value       = aws_rds_cluster.dev_aurora_cluster.endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint of the Aurora Cluster (Dev)"
  value       = aws_rds_cluster.dev_aurora_cluster.reader_endpoint
}

output "aurora_security_group_id" {
  description = "Security Group ID associated with the Aurora Cluster (Dev)"
  value       = module.dev_aurora_sg.security_group_id
}

output "aurora_subnet_group_name" {
  description = "Subnet Group Name of the Aurora Cluster (Dev)"
  value       = aws_db_subnet_group.dev_aurora_subnet_group.name
}
