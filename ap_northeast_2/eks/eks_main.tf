module "eks_module" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = [for subnet in var.subnets.eks_subnets : subnet.id]
  cluster_name    = "${var.project_name}-eks-cluster-01"
  cluster_version = "1.26"

  cluster_endpoint_public_access  = true

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

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    ("${var.project_name}-node-group") = {
      min_size     = 2 
      max_size     = 2
      desired_size = 2

      labels = {
        node = "test_node"
      }
    }
  }
  
}
