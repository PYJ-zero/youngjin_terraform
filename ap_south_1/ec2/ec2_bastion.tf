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

  name = "${var.project_name}-ec2-bastion"

  instance_type          = "t3a.nano"
  monitoring             = true
  vpc_security_group_ids = [var.security_groups.bastion_sg.id]
  subnet_id              = var.subnets.private_pri_a_subnets.id
  iam_instance_profile = var.iam_ssm_profile.name
  
  # 여기서 ami 파라미터에 Data Source의 id를 전달
  ami = data.aws_ami.amazon_linux_2023.id
  
  # IMDSv2만 사용하도록 metadata_options 설정 (IMDSv1 비활성화)
  metadata_options = {
    http_tokens               = "required"  # 토큰 없이 접근 불가 → IMDSv2 강제
    http_put_response_hop_limit = 2         # 응답 hop 제한 (필요에 따라 조정)
    http_endpoint             = "enabled"   # 메타데이터 엔드포인트 활성화
  }

  # 사용자 데이터 (user_data) 스크립트: kubectl 설치 및 kubeconfig 업데이트  
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # 최신 업데이트 및 awscli, curl 설치 (Amazon Linux 2023 기준)
    yum update -y
    yum install -y awscli curl vim

    # EKS 클러스터 버전에 맞는 kubectl 설치
    curl -o /usr/local/bin/kubectl "https://amazon-eks.s3.us-west-2.amazonaws.com/${var.eks_cluster.cluster_version}/2021-07-05/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

    # Terraform 변수에 설정된 리전과 EKS 클러스터 이름을 사용해 kubeconfig 업데이트
    aws eks update-kubeconfig --region ${var.region_code} --name ${var.eks_cluster.cluster_name}
  EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}