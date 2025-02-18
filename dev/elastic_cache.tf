resource "aws_elasticache_subnet_group" "example" {
  name       = "dev-elasticache-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "elasticache_sg" {
  name        = "dev-elasticache-security-group"
  description = "Allow inbound traffic to Elasticache"

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

resource "aws_elasticache_cluster" "example" {
  cluster_id           = "dev-redis-cluster"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis7"
  engine_version      = "7.0"
  port                = 6379
  subnet_group_name   = aws_elasticache_subnet_group.example.name
  security_group_ids  = [aws_security_group.elasticache_sg.id]

  tags = {
    Name = "MyRedisCluster"
  }
}
