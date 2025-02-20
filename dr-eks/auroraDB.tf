

# 서브넷 그룹 생성
resource "aws_db_subnet_group" "aurora_subnet_group_eks" {
  name       = "aurora-subnet-group-eks"
  subnet_ids = module.vpc-eks.private_subnets  # VPC 서브넷 사용

  tags = {
    Name = "AuroraSubnetGroupEKS"
  }
}

data "terraform_remote_state" "aurora_primary_state" {
  backend = "s3"

  config = {
    bucket = "snowduck-terraform-state"
    key = "dev/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}


# Aurora 보조 클러스터 생성 (EKS 연계)
resource "aws_rds_cluster" "aurora_secondary_eks" {
  cluster_identifier        = "aurora-secondary-cluster-eks"
  global_cluster_identifier  = data.terraform_remote_state.aurora_primary_state.outputs.aurora_global_cluster_id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.2"  # 최신 지원 버전으로 변경
  db_subnet_group_name      = aws_db_subnet_group.aurora_subnet_group_eks.name
  vpc_security_group_ids    = [module.aurora_sg_eks.security_group_id]  # 보안 그룹 사용
  skip_final_snapshot       = true
  apply_immediately         = true

  tags = {
    Name = "AuroraSecondaryEKS"
  }
}

# 보안 그룹 생성 (EKS 연계)
module "aurora_sg_eks" {
  source = "../modules/security_group"

  name   = "aurora-sg-eks"
  vpc_id = module.vpc-eks.vpc_id

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




# 🔹 Aurora 보조 클러스터 출력값 추가 (EKS)
output "aurora_secondary_cluster_endpoint_eks" {
  description = "Endpoint of the Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.aurora_secondary_eks.endpoint
}

output "aurora_secondary_reader_endpoint_eks" {
  description = "Reader endpoint of the Aurora Secondary Cluster (EKS)"
  value       = aws_rds_cluster.aurora_secondary_eks.reader_endpoint
}

output "aurora_secondary_security_group_id_eks" {
  description = "Security Group ID associated with the Aurora Secondary Cluster (EKS)"
  value       = module.aurora_sg_eks.security_group_id
}

output "aurora_secondary_subnet_group_name_eks" {
  description = "Subnet Group Name of the Aurora Secondary Cluster (EKS)"
  value       = aws_db_subnet_group.aurora_subnet_group_eks.name
}
