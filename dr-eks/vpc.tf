module "dr_eks_vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dr-vpc-eks"
  vpc_cidr  = "10.1.0.0/16"

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  
  availability_zones = ["us-east-2a", "us-east-2c"]

  nat_gateways = ["dr-eks-nat-gw-1", "dr-eks-nat-gw-2"]

  public_subnets_name  = ["dr-eks-public-subnet-1", "dr-eks-public-subnet-2"]
  private_subnets_name = ["dr-eks-private-subnet-1", "dr-eks-private-subnet-2","dr-eks-private-subnet-3","dr-eks-private-subnet-4"]

  internet_gateway  = "dr-eks-igw"
  public_route_table = "dr-eks-public-rt"
  private_route_tables = ["dr-eks-private-rt-1", "dr-eks-private-rt-2"]
}

# EKS VPC 출력값
output "dr_eks_vpc_id" {
  value = module.dr_eks_vpc.vpc_id
}

output "dr_eks_public_subnets" {
  value = module.dr_eks_vpc.public_subnets
}

output "dr_eks_private_subnets" {
  value = module.dr_eks_vpc.private_subnets
}
