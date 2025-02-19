resource "aws_elasticache_subnet_group" "elasticcache_subnet_group" {
  name       = "dev-elasticache-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "elasticache_sg" {
  name        = "dev-elasticache-security-group"
  description = "Allow inbound traffic to Elasticache"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elasticache-sg"
  }
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = "dev-redis-cluster"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis7"
  engine_version      = "7.0"
  port                = 6379
  subnet_group_name   = aws_elasticache_subnet_group.elasticcache_subnet_group.name
  security_group_ids  = [aws_security_group.elasticache_sg.id]

  tags = {
    Name = "MyRedisCluster"
  }
}

output "elasticache_cluster_id" {
  description = "ElastiCache 클러스터의 ID"
  value       = aws_elasticache_cluster.elasticache_cluster.id
}

output "elasticache_primary_endpoint" {
  description = "ElastiCache 클러스터의 기본 엔드포인트 주소"
  value       = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].address
}

output "elasticache_port" {
  description = "ElastiCache 클러스터의 포트 번호"
  value       = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].port
}
