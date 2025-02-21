module "prod_vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "prod-vpc"
  vpc_cidr  = "10.3.0.0/16"

  public_subnet_cidrs  = ["10.3.1.0/24","10.3.2.0/24"]
  private_subnet_cidrs = ["10.3.3.0/24","10.3.4.0/24", "10.3.5.0/24","10.3.6.0/24"]
  
  availability_zones = ["ap-northeast-2a","ap-northeast-2c"]

  nat_gateways = ["prod-nat-gw-1", "prod-nat-gw-2"]

  public_subnets_name  = ["prod-public-subnet-1", "prod-public-subnet-2"]
  private_subnets_name = ["prod-private-subnet-1", "prod-private-subnet-2", "prod-private-subnet-3","prod-private-subnet-4"]

  internet_gateway  = "prod-igw"
  public_route_table = "prod-public-rt"
  private_route_tables = ["prod-private-rt-1", "prod-private-rt-2"]
  
}


# EKS VPC 출력값
output "eks_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "eks_public_subnets" {
  value = module.prod_vpc.public_subnets
}

output "eks_private_subnets" {
  value = module.prod_vpc.private_subnets
}
