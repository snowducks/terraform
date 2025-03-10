# VPC 생성 (EKS용)
module "dr_eks_vpc" {
  source = "../modules/vpc"  # VPC 모듈 경로 설정

  vpc_name  = "dr-vpc-eks"
  vpc_cidr  = "10.1.0.0/16"  # VPC CIDR 블록

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]  # 퍼블릭 서브넷
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]  # 프라이빗 서브넷

  availability_zones = ["ap-southeast-1a", "ap-southeast-1c"]  # 가용 영역 설정

  nat_gateways = ["dr-eks-nat-gw-1", "dr-eks-nat-gw-2"]  # NAT 게이트웨이 설정

  public_subnets_name  = ["dr-eks-public-subnet-1", "dr-eks-public-subnet-2"]
  private_subnets_name = ["dr-eks-private-subnet-1", "dr-eks-private-subnet-2", "dr-eks-private-subnet-3", "dr-eks-private-subnet-4"]

  internet_gateway    = "dr-eks-igw"
  public_route_table  = "dr-eks-public-rt"
  private_route_tables = ["dr-eks-private-rt-1", "dr-eks-private-rt-2"]
}

# EKS VPC 출력값

output "dr_eks_vpc_id" {
  description = "EKS 클러스터가 배포된 VPC의 ID"
  value       = module.dr_eks_vpc.vpc_id
}

output "dr_eks_public_subnets" {
  description = "EKS용 퍼블릭 서브넷 ID 목록"
  value       = module.dr_eks_vpc.public_subnets
}

output "dr_eks_private_subnets" {
  description = "EKS용 프라이빗 서브넷 ID 목록"
  value       = module.dr_eks_vpc.private_subnets
}
