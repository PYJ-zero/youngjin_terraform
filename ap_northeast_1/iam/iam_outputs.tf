output "iam_role" {
  value = {
    ssm_role = aws_iam_role.ssm_role
    ssm_instance_profile = aws_iam_instance_profile.ssm_instance_profile
  }
}