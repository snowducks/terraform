resource "aws_rds_global_cluster" "aurora_global" {
  global_cluster_identifier = "aurora-global-cluster"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전으로 변경
  database_name             = "example_db"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets  # VPC 모듈에서 서브넷 가져오기

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
