module "dr_ecs_vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dr-vpc-ecs"
  vpc_cidr  = "10.2.0.0/16"

  public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs = ["10.2.3.0/24","10.2.4.0/24"]
  
  availability_zones = ["us-east-2a","us-east-2c"]
}


# ECS VPC 출력값
output "dr_ecs_vpc_id" {
  value = module.dr_ecs_vpc.vpc_id
}

output "dr_ecs_public_subnets" {
  value = module.dr_ecs_vpc.public_subnets
}

output "dr_ecs_private_subnets" {
  value = module.dr_ecs_vpc.private_subnets
}
