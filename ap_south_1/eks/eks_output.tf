output "eks" {
  value = {
    cluster_name     = module.eks.cluster_name
    cluster_version  = module.eks.cluster_version
  }
}
