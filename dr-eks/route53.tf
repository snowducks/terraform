

resource "aws_route53_record" "prod" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "서울 rout53"

  alias {
    name                   = "d3d7fig0qrvk2p.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 0
  }
}

resource "aws_route53_record" "dr_ecs" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "dr-ecs 로드밸런서"

  alias {
    name                   = "dualstack.dr-ecs-lb-564638976.ap-southeast-1.elb.amazonaws.com"
    zone_id                = "Z1LMS91P8CMLE5"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10
  }
}



# ✅ DR 환경 #2 (EKS, 평소 0%)
resource "aws_route53_record" "dr_eks" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "dr-eks 로드밸런서"

  alias {
    name                   = "dr-eks-alb-101966728.ap-southeast-1.elb.amazonaws.com"
    zone_id                = "Z1LMS91P8CMLE5"
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10
  }
}
