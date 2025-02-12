module "security_group" {
  source  = "../../modules/security_group"

  name    = "my-security-group"
  vpc_id  = "vpc-0450f7a9e5a32c273"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # SSH 허용
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # HTTP 허용
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # HTTPS 허용
    }
  ]
}
