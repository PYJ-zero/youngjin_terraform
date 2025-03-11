data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [ module.eks ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
module "eks_cluster_access_role" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = var.iam_roles.eks_node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = var.iam_roles.ssm_role.arn
      username = "bastion-assume-role"
      groups   = ["system:masters"]
    }
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.project_name}-eks-cluster-01"
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = [for subnet in var.subnets.eks_subnets : subnet.id]
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_iam_role = false
  iam_role_arn = var.iam_roles.eks_cluster_role.arn

  # 자동으로 cluster creator(현재 Terraform을 실행하는 주체)를 admin으로 등록하지 않도록 false로 설정
  enable_cluster_creator_admin_permissions = true


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  # Bastion에서 EKS API 서버(443)에 접근할 수 있도록 추가 규칙 추가
  cluster_security_group_additional_rules = {
    bastion_access = {
      description     = "Allow Bastion SG access to EKS API server"
      type            = "ingress"
      protocol        = "tcp"
      from_port       = 443
      to_port         = 443
      source_security_group_id = var.security_groups.bastion_sg.id
    }
  }

  eks_managed_node_groups = {
    "${var.project_name}-nodegroup-1" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3a.medium"]
      create_worker_iam_role = false
      worker_iam_role_arn = var.iam_roles.eks_node_role.arn
      name           = "${var.project_name}-ng-1"
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
  }

  tags = {
    Project = "${var.project_name}-eks-cluster"
  }
}
