# EKS Cluster 생성

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.project_name}-eks-cluster-01"
  vpc_id          = var.vpc_id
  subnet_ids      = [for subnet in var.subnets.eks_subnets : subnet.id]
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_iam_role = false
  iam_role_arn    = var.iam_roles.eks_cluster_role.arn

  # 자동으로 cluster creator(현재 Terraform을 실행하는 주체)를 admin으로 등록하지 않도록 하려면 false로 설정
  enable_cluster_creator_admin_permissions = true

  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {}
    aws-ebs-csi-driver = {}
    }
  
  # Bastion에서 EKS API 서버(443)에 접근할 수 있도록 추가 규칙 추가
  cluster_security_group_additional_rules = {
    bastion_access = {
      description              = "Allow Bastion SG access to EKS API server"
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      source_security_group_id = var.security_groups.bastion_sg.id
    }
  }

  eks_managed_node_groups = {
    "${var.project_name}-nodegroup-1" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type               = "BOTTLEROCKET_x86_64"
      instance_types         = ["t3a.medium"]
      create_worker_iam_role = false
      worker_iam_role_arn    = var.iam_roles.eks_node_role.arn
      name                   = "${var.project_name}-ng-1"
      min_size               = 2
      max_size               = 2
      desired_size           = 2
    }
  }

  access_entries = {
    # One access entry with a policy associated
    ssm_role_access = {
      principal_arn = var.iam_roles.ssm_role.arn

      policy_associations = {
        eks_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        cluster_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Project = "${var.project_name}-eks-cluster"
  }
}
