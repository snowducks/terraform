# 기본 프로덕션 환경 (서울 CloudFront, 기본 가중치 0)
resource "aws_route53_record" "prod" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "서울 Route53 (CloudFront)"

  alias {
    name                   = "d3d7fig0qrvk2p.cloudfront.net"  # CloudFront 도메인
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 0  # 기본적으로 트래픽을 보내지 않음 (DR을 위해 설정)
  }
}

# DR 환경 #1 (ECS, 가중치 10%)
resource "aws_route53_record" "dr_ecs" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "DR ECS 로드밸런서"

  alias {
    name                   = "dualstack.dr-ecs-lb-564638976.ap-southeast-1.elb.amazonaws.com"
    zone_id                = "Z1LMS91P8CMLE5"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10  # 트래픽의 10%를 ECS DR 환경으로 라우팅
  }
}

# DR 환경 #2 (EKS, 가중치 10%)
resource "aws_route53_record" "dr_eks" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "DR EKS 로드밸런서"

  alias {
    name                   = "dr-eks-alb-101966728.ap-southeast-1.elb.amazonaws.com"
    zone_id                = "Z1LMS91P8CMLE5"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10  # 트래픽의 10%를 EKS DR 환경으로 라우팅
  }
}
