# security_group 모듈을 사용한 ALB 보안 그룹 생성
module "dr_eks_alb_security_group" {
  source = "../modules/security_group"  # 보안 그룹 모듈 경로
  name   = "dr-eks-alb-security-group"
  vpc_id = module.dr_eks_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # HTTP 트래픽 개방
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # HTTPS 트래픽 개방
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]  # 필요하면 특정 CIDR로 제한 가능
    }
  ]
}

# ALB 생성
resource "aws_lb" "dr_eks_alb" {
  name               = "dr-eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.dr_eks_alb_security_group.security_group_id]
  subnets            = module.dr_eks_vpc.public_subnets
}

# Target Group 생성 (EKS 서비스와 연결)
resource "aws_lb_target_group" "dr_eks_tg" {
  name        = "dr-eks-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dr_eks_vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ALB Listener 추가 (HTTP)
resource "aws_lb_listener" "dr_eks_http_listener" {
  load_balancer_arn = aws_lb.dr_eks_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dr_eks_tg.arn
  }
}

# 출력값 (Output)

output "dr_eks_alb_dns_name" {
  description = "DR EKS ALB의 퍼블릭 DNS 이름 (웹 서비스에 사용)"
  value       = aws_lb.dr_eks_alb.dns_name
}

output "dr_eks_alb_zone_id" {
  description = "DR EKS ALB가 속한 Route53 Hosted Zone ID"
  value       = aws_lb.dr_eks_alb.zone_id
}

output "dr_eks_alb_arn" {
  description = "DR EKS ALB의 Amazon Resource Name (ARN)"
  value       = aws_lb.dr_eks_alb.arn
}

output "dr_eks_alb_security_group_id" {
  description = "DR EKS ALB에 적용된 보안 그룹 ID"
  value       = module.dr_eks_alb_security_group.security_group_id
}
