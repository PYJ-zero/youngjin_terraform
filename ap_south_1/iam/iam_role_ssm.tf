# (1) IAM 역할 생성
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-role-ssm"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# (2) AmazonSSMManagedInstanceCore 정책을 역할에 연결
resource "aws_iam_role_policy_attachment" "bastion_attach_admin_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# (3) 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project_name}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
