data "terraform_remote_state" "prod_data" {
  backend = "s3"

  config = {
    bucket = "prod-snowduck-terraform-state"
    key    = "prod/state-storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "dr_ecs" {
  backend = "s3"

  config = {
    bucket = "dr-ecs-snowduck-terraform-state"
    key    = "dr-ecs/state-storage/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "dr_eks" {
  backend = "s3"

  config = {
    bucket = "dr-eks-snowduck-terraform-state"
    key    = "dr-eks/state-storage/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "aws_route53_record" "dr_ecs" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "dr-ecs 로드밸런서"

  alias {
    name                   = data.terraform_remote_state.prod_data.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.prod_data.outputs.alb_zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10
  }
}


resource "aws_route53_record" "prod" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "서울 rout53"

  alias {
    name                   = data.terraform_remote_state.dr_ecs.outputs.dr_ecs_lb_dns_name
    zone_id                = data.terraform_remote_state.dr_ecs.outputs.dr_ecs_lb_zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 0
  }
}

# ✅ DR 환경 #2 (EKS, 평소 0%)
resource "aws_route53_record" "dr_eks" {
  zone_id        = "Z10135492GRSUH9J9TX7E"
  name           = "twinkleticket.store"
  type           = "A"
  set_identifier = "dr-eks 로드밸런서"

  alias {
    name                   = data.terraform_remote_state.dr_eks.outputs.dr_eks_alb_dns_name
    zone_id                = data.terraform_remote_state.dr_eks.outputs.dr_eks_alb_zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = 10
  }
}
