# 서브넷 그룹 생성
resource "aws_db_subnet_group" "dr_eks_aurora_subnet_group" {
  name       = "dr-eks-aurora-subnet-group"
  subnet_ids = module.dr_eks_vpc.private_subnets  # VPC의 프라이빗 서브넷 사용

  tags = {
    Name = "dr-eks-aurora-subnet-group"
  }
}

# 기존 Aurora Primary 클러스터 상태 로드 (S3 백엔드에서)
data "terraform_remote_state" "aurora_primary_state" {
  backend = "s3"

  config = {
    bucket = "prod-snowduck-terraform-state"
    key    = "prod/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# 기존 Aurora 보조 클러스터 정보 가져오기
data "aws_rds_cluster" "dr_eks_aurora_secondary" {
  cluster_identifier = "dr-ecs-aurora-secondary-cluster"
}

# Aurora 보조 클러스터 (EKS) - Read Replica 인스턴스 추가
resource "aws_rds_cluster_instance" "dr_eks_aurora_secondary_reader" {
  count                = 1  # 읽기 전용 인스턴스 개수 (필요시 조정 가능)
  identifier           = "dr-eks-aurora-secondary-reader-${count.index}"
  cluster_identifier   = data.aws_rds_cluster.dr_eks_aurora_secondary.id  # 기존 클러스터에 연결
  instance_class       = "db.r5.large"  # Aurora MySQL 인스턴스 유형
  engine              = "aurora-mysql"
  publicly_accessible  = false  # 외부 접근 불가
  apply_immediately    = true
}

# 보안 그룹 생성 (EKS 연계)
module "dr_eks_aurora_sg" {
  source = "../modules/security_group"

  name   = "dr-eks-aurora-sg"
  vpc_id = module.dr_eks_vpc.vpc_id

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
      cidr_blocks = ["0.0.0.0/0"]  # 모든 아웃바운드 트래픽 허용
    }
  ]
}

# 출력값 (Output)

output "dr_eks_aurora_secondary_reader_instances" {
  description = "DR Aurora 보조 클러스터 (EKS)의 Read Replica 인스턴스 목록"
  value       = aws_rds_cluster_instance.dr_eks_aurora_secondary_reader[*].id
}

output "dr_eks_aurora_secondary_security_group_id" {
  description = "DR Aurora 보조 클러스터 (EKS)에 적용된 보안 그룹 ID"
  value       = module.dr_eks_aurora_sg.security_group_id
}

output "dr_eks_aurora_secondary_subnet_group_name" {
  description = "DR Aurora 보조 클러스터 (EKS)의 서브넷 그룹 이름"
  value       = aws_db_subnet_group.dr_eks_aurora_subnet_group.name
}
