resource "aws_security_group" "eks_sg" {
  name   = "eks_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  enable_cluster_creator_admin_permissions = true # 해결

  cluster_name    = "eks_cluster"
  cluster_version = "1.32"

  vpc_id                         = module.vpc-eks.vpc_id
  subnet_ids                     = module.vpc-eks.private_subnets
  cluster_security_group_id      = aws_security_group.eks_sg.id
  cluster_additional_security_group_ids = [aws_security_group.eks_sg.id]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
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


data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

output "eks_cluster_id" {
  description = "EKS 클러스터의 ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터의 엔드포인트 URL"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS 클러스터에 연결된 보안 그룹 ID"
  value       = module.eks.cluster_security_group_id
}