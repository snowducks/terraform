resource "aws_security_group" "dev_eks_sg" {
  name   = "dev-eks-sg"
  vpc_id = module.dev_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "dev_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  enable_cluster_creator_admin_permissions = true
  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.31"

  vpc_id                         = module.dev_vpc.vpc_id
  subnet_ids                     = module.dev_vpc.private_subnets
  cluster_security_group_id      = aws_security_group.dev_eks_sg.id
  cluster_additional_security_group_ids = [aws_security_group.dev_eks_sg.id]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "dev-node-group-1"

      instance_types = ["c6i.xlarge"]

      min_size     = 2
      max_size     = 15
      desired_size = 3
    }
  }
}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::796973504685:role/kube-test-role"
      username = "developer"
      groups   = ["system:masters"]
    }
  ]

   aws_auth_users = [
    {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-csh"
      username = "csh"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-cwy"
      username = "cwy"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-kdy"
      username = "kdy"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-keb"
      username = "keb"
      groups   = ["system:masters"]
    },
        {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-phj"
      username = "phj"
      groups   = ["system:masters"]
    },
        {
      userarn  = "arn:aws:iam::796973504685:user/snowduck-ysy"
      username = "ysy"
      groups   = ["system:masters"]
    }
  ]
}

data "aws_eks_cluster" "dev_eks_cluster" {
  name = module.dev_eks.cluster_name
  depends_on = [module.dev_eks]
}

data "aws_eks_cluster_auth" "default" {
  name = module.dev_eks.cluster_name
  depends_on = [module.dev_eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.dev_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

output "eks_cluster_id" {
  description = "dev 환경 EKS 클러스터 ID"
  value       = module.dev_eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "dev 환경 EKS 클러스터 엔드포인트 URL"
  value       = module.dev_eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "dev 환경 EKS 클러스터에 연결된 보안 그룹 ID"
  value       = module.dev_eks.cluster_security_group_id
}