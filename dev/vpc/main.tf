module "vpc" {
  source = "../../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dev-vpc"
  vpc_cidr  = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
}

# 출력값 확인
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
