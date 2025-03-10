# security_group 모듈을 사용한 ALB 보안 그룹
module "prod_alb_security_group" {
  source      = "../modules/security_group"
  name        = "prod-alb-security-group"
  vpc_id      = module.prod_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_lb" "prod_eks_alb" {
  name               = "prod-eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.prod_alb_security_group.security_group_id]
  subnets =  module.prod_vpc.public_subnets
}

# EKS 연결하는 target group 생성
resource "aws_lb_target_group" "prod_eks_tg" {
  name     = "prod-eks-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.prod_vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ALB Listener 생성
resource "aws_lb_listener" "prod_http_listener" {
  load_balancer_arn = aws_lb.prod_eks_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_eks_tg.arn
  }
}

# ALB Listener 추가
resource "aws_lb_listener" "prod_https_listener" {
  load_balancer_arn = aws_lb.prod_eks_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_eks_tg.arn
  }
}

# PROD ALB DNS 이름 출력
output "alb_dns_name" {
  description = "prod EKS ALB DNS 이름"
  value       = aws_lb.prod_eks_alb.dns_name
}

# PROD ALB의 Route53 Zone ID 출력
output "alb_zone_id" {
  description = "prod EKS ALB Route53 Zone ID"
  value       = aws_lb.prod_eks_alb.zone_id
}
