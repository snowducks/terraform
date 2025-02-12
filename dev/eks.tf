module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "eks_cluster"
  cluster_version = "1.32"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
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

