output "iam_roles" {
  value = {
    ssm_role = aws_iam_role.ssm_role
    eks_node_role = aws_iam_role.eks_node_role
    eks_cluster_role = aws_iam_role.eks_cluster_role
    ssm_instance_profile = aws_iam_instance_profile.ssm_instance_profile
  }
}