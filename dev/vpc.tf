module "vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dev-vpc"
  vpc_cidr  = "10.0.0.0/16"

  # bastion
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

  nat_gateways = ["dev-nat-gw-1", "dev-nat-gw-2"]

  public_subnets_name  = ["dev-public-subnet-1", "dev-public-subnet-2"]
  private_subnets_name = ["dev-private-subnet-1", "dev-private-subnet-2"]

  internet_gateway  = "dev-igw"
  public_route_table = "dev-public-rt"
  private_route_tables = ["dev-private-rt-1", "dev-private-rt-2"]

}

# 출력값 확인
output "vpc_id" {
  value = module.vpc.vpc_id 
}

