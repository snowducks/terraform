# ECS 클러스터 설정
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = ">= 3.69, < 5.0"

  cluster_name = "dr-ecs-cluster"
}

# ECS 태스크 정의 (Fargate)
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "dr-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "dr-container"
      image     = "796973504685.dkr.ecr.ap-northeast-2.amazonaws.com/dev-ecr:latest"  # ECR 이미지 사용
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECS IAM 역할 (태스크 실행)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "dr-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECR Pull 권한 추가
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_readonly_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 추가: ECS 태스크가 SSM 및 Secrets Manager에서 환경변수를 가져올 수 있도록 권한 부여
resource "aws_iam_role_policy_attachment" "ecs_ssm_secrets_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# ECS 서비스 생성 (Fargate)
resource "aws_ecs_service" "ecs_service" {
  name            = "dr-ecs-service"
  cluster         = module.ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc-ecs.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false  # Private Subnet에서 실행하도록 설정 (인터넷 접근 필요 시 NAT Gateway 필요)
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "dr-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# 보안 그룹 설정 (ECS)
resource "aws_security_group" "ecs_sg" {
  vpc_id = module.vpc-ecs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 보안을 위해 특정 IP 대역으로 변경 권장 (예: 회사 VPN, 특정 VPC)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 로드밸런서 설정
resource "aws_lb" "ecs_lb" {
  name               = "dr-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets           = module.vpc-ecs.public_subnets
}

resource "aws_lb_target_group" "ecs_target_group" {
  name     = "dr-ecs-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc-ecs.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

# 출력값
output "ecs_cluster_id" {
  description = "ECS 클러스터 ID"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_service_name" {
  description = "ECS 서비스 이름"
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_lb_dns_name" {
  description = "ECS 로드밸런서 DNS"
  value       = aws_lb.ecs_lb.dns_name
}
