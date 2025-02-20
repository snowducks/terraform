# security_group 모듈을 사용한 ALB 보안 그룹 생성
module "alb_security_group" {
  source      = "../modules/security_group"  # 보안 그룹 모듈 경로
  name        = "alb-security-group"
  vpc_id      = module.vpc-eks.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # HTTP 개방 (보안 필요 시 수정)
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # HTTPS 개방 (보안 필요 시 수정)
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ALB 생성
resource "aws_lb" "eks_alb" {
  name               = "eks-alb"
  internal           = true  # ALB 내부 위치
  load_balancer_type = "application"
  security_groups    = [module.alb_security_group.security_group_id]
  subnets = [module.vpc-eks.private_subnets[0], module.vpc-eks.private_subnets[3]]  
}

# Target Group 생성 (EKS 서비스와 연결)
resource "aws_lb_target_group" "eks_tg" {
  name     = "eks-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc-eks.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ALB Listener 추가 (HTTP)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_tg.arn
  }
}

# ALB Listener 추가 (HTTPS)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_tg.arn
  }
}
