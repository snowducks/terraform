module "dr_eks_vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dr-vpc-eks"
  vpc_cidr  = "10.1.0.0/16"

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  
  availability_zones = ["us-east-2a", "us-east-2c"]
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
