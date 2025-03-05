# 1. Amazon Linux 2023 AMI를 조회하는 Data Source
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]    # AWS 공식 AMI
  filter {
    name   = "name"
    values = ["al2023-ami-*"] # Amazon Linux 2023 이미지 이름 패턴
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

# 2. EC2 인스턴스 생성 모듈
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-ec2-bastion-02"

  instance_type          = "t3a.nano"
  monitoring             = true
  vpc_security_group_ids = [var.security_groups.bastion_sg.id]
  subnet_id              = var.subnets.private_pri_a_subnets.id

  # 여기서 ami 파라미터에 Data Source의 id를 전달
  ami = data.aws_ami.amazon_linux_2023.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  iam_instance_profile = var.iam_instance_profile.id
  }
}