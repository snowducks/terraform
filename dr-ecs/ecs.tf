# ✅ ECS 클러스터 생성
module "dr_ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = ">= 3.69, < 5.0"

  cluster_name = "dr-ecs-cluster"
}

# ✅ ECS IAM 역할 (태스크 실행)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ✅ IAM 정책 추가 (ECR Pull, SSM 접근)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_readonly_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_ssm_secrets_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# ✅ 보안 그룹 설정 (ECS, Kafka, ALB, Websocket)
resource "aws_security_group" "dr_ecs_sg" {
  vpc_id = module.dr_ecs_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080  # ✅ Websocket 포트 추가
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092  # ✅ Kafka 포트 추가
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ ECS Task Definitions

# ✅ Kafka Consumer Task
resource "aws_ecs_task_definition" "kafka_consumer" {
  family                   = "kafka-consumer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kafka-consumer"
      image     = "796973504685.dkr.ecr.ap-northeast-2.amazonaws.com/server/kafka-consumer:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{ containerPort = 9092 }]
    }
  ])
}

# ✅ Kafka Producer Task
resource "aws_ecs_task_definition" "kafka_producer" {
  family                   = "kafka-producer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kafka-producer"
      image     = "796973504685.dkr.ecr.ap-northeast-2.amazonaws.com/server/kafka-producer:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{ containerPort = 9092 }]
    }
  ])
}

# ✅ Frontend Task
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "796973504685.dkr.ecr.ap-northeast-2.amazonaws.com/server/olive-young-fe:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{ containerPort = 80 }]
    }
  ])
}

# ✅ Websocket Task
resource "aws_ecs_task_definition" "websocket" {
  family                   = "websocket-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "websocket"
      image     = "796973504685.dkr.ecr.ap-northeast-2.amazonaws.com/server/websocket:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{ containerPort = 8080 }]
    }
  ])
}

# ✅ Load Balancer 설정
resource "aws_lb" "dr_ecs_lb" {
  name               = "dr-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dr_ecs_sg.id]
  subnets           = module.dr_ecs_vpc.public_subnets
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dr_ecs_vpc.vpc_id
  target_type = "ip"
}


resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.dr_ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


# ✅ 출력값
output "dr_ecs_cluster_id" { value = module.dr_ecs_cluster.cluster_id }
output "dr_ecs_lb_dns_name" { value = aws_lb.dr_ecs_lb.dns_name }

output "dr_ecs_lb_zone_id" { 
  value = aws_lb.dr_ecs_lb.zone_id 
}