# VPC 생성 (ECS용)
module "dr_ecs_vpc" {
  source = "../modules/vpc"  # 모듈 경로 설정

  vpc_name  = "dr-vpc-ecs"
  vpc_cidr  = "10.2.0.0/16"

  public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs = ["10.2.3.0/24","10.2.4.0/24"]
  
  availability_zones = ["ap-southeast-1a","ap-southeast-1c"]

  nat_gateways = ["dr-ecs-nat-gw-1", "dr-ecs-nat-gw-2"]

  public_subnets_name  = ["dr-ecs-public-subnet-1", "dr-ecs-public-subnet-2"]
  private_subnets_name = ["dr-ecs-private-subnet-1", "dr-ecs-private-subnet-2"]

  internet_gateway  = "dr-ecs-igw"
  public_route_table = "dr-ecs-public-rt"
  private_route_tables = ["dr-ecs-private-rt-1", "dr-ecs-private-rt-2"]
}


# ECS VPC 출력값

output "dr_ecs_vpc_id" {
  description = "ECS 클러스터가 속한 VPC의 ID"
  value       = module.dr_ecs_vpc.vpc_id
}

output "dr_ecs_public_subnets" {
  description = "ECS용 퍼블릭 서브넷 ID 목록"
  value       = module.dr_ecs_vpc.public_subnets
}

output "dr_ecs_private_subnets" {
  description = "ECS용 프라이빗 서브넷 ID 목록"
  value       = module.dr_ecs_vpc.private_subnets
}