# ElastiCache Subnet Group 생성
resource "aws_elasticache_subnet_group" "dr_ecs_elasticache_subnet_group" {
  name       = "dr-ecs-elasticache-subnet-group"
  subnet_ids = module.dr_ecs_vpc.private_subnets

  tags = {
    Name = "dr-ecs-elasticache-subnet-group"
  }
}

# 보안 그룹 생성 (ElastiCache Redis용)
resource "aws_security_group" "dr_ecs_elasticache_sg" {
  name        = "dr-ecs-elasticache-security-group"
  description = "ElastiCache Redis 클러스터 보안 그룹"
  vpc_id      = module.dr_ecs_vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [module.dr_ecs_vpc.vpc_cidr_block]  # VPC 내부에서만 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # 필요하면 특정 CIDR로 제한 가능
  }

  tags = {
    Name = "dr-ecs-elasticache-sg"
  }
}

# ElastiCache Redis 클러스터 생성
resource "aws_elasticache_cluster" "dr_ecs_elasticache_cluster" {
  cluster_id           = "dr-ecs-elasticcache-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.dr_ecs_elasticache_subnet_group.name
  security_group_ids   = [aws_security_group.dr_ecs_elasticache_sg.id]

  tags = {
    Name = "dr-ecs-elasticache-cluster"
  }
}

# 출력값 (Output)

output "dr_ecs_elasticache_cluster_id" {
  description = "ElastiCache Redis 클러스터의 ID"
  value       = aws_elasticache_cluster.dr_ecs_elasticache_cluster.id
}

output "dr_ecs_elasticache_primary_endpoint" {
  description = "ElastiCache Redis 클러스터의 기본 엔드포인트 주소"
  value       = aws_elasticache_cluster.dr_ecs_elasticache_cluster.primary_endpoint_address
}

output "dr_ecs_elasticache_port" {
  description = "ElastiCache Redis 클러스터의 포트 번호"
  value       = aws_elasticache_cluster.dr_ecs_elasticache_cluster.port
}
