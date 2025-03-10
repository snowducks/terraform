# Aurora Subnet Group
resource "aws_db_subnet_group" "dev_aurora_subnet_group" {
  name       = "dev-aurora-subnet-group"
  subnet_ids = module.dev_vpc.private_subnets
  tags = {
    Name = "dev-aurora-subnet-group"
  }
}

# dev 환경에서만 사용할 Aurora Cluster
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

# Aurora Cluster의 Writer 노드
resource "aws_rds_cluster_instance" "dev_aurora_instance" {
  count                = 2
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

output "aurora_cluster_endpoint" {
  description = "dev 환경 Aurora 클러스터의 Writer 엔드포인트"
  value       = aws_rds_cluster.dev_aurora_cluster.endpoint
}

output "aurora_reader_endpoint" {
  description = "dev 환경 Aurora 클러스터의 Reader 엔드포인트"
  value       = aws_rds_cluster.dev_aurora_cluster.reader_endpoint
}

output "aurora_security_group_id" {
  description = "dev 환경 Aurora 클러스터에 연결된 보안 그룹 ID"
  value       = module.dev_aurora_sg.security_group_id
}

output "aurora_subnet_group_name" {
  description = "dev 환경 Aurora 클러스터의 서브넷 그룹 이름"
  value       = aws_db_subnet_group.dev_aurora_subnet_group.name
}
