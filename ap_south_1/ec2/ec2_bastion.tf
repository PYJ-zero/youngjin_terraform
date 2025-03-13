# 1. Amazon Linux 2023 AMI를 조회하는 Data Source
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # AWS 공식 AMI
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
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-ec2-bastion"

  instance_type          = "t3a.nano"
  monitoring             = true
  vpc_security_group_ids = [var.security_groups.bastion_sg.id]
  subnet_id              = var.subnets.private_pri_a_subnets.id
  iam_instance_profile   = var.iam_ssm_profile.name

  # 여기서 ami 파라미터에 Data Source의 id를 전달
  ami = data.aws_ami.amazon_linux_2023.id

  # IMDSv2만 사용하도록 metadata_options 설정 (IMDSv1 비활성화)
  metadata_options = {
    http_tokens                 = "required" # 토큰 없이 접근 불가 → IMDSv2 강제
    http_put_response_hop_limit = 2          # 응답 hop 제한 (필요에 따라 조정)
    http_endpoint               = "enabled"  # 메타데이터 엔드포인트 활성화
  }

  # 사용자 데이터 (user_data) 스크립트: kubectl 설치 및 kubeconfig 업데이트  
  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    ### 최신 업데이트 및 awscli, curl 설치 (Amazon Linux 2023 기준)
    ##############################
    yum update -y
    yum install -y awscli vim git

    ### EKS 클러스터 버전에 맞는 kubectl 설치
    ##############################
    export HOME=/root
    cd $HOME
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

    ### Terraform 변수에 설정된 리전과 EKS 클러스터 이름을 사용해 kubeconfig 업데이트
    ##############################
    aws eks update-kubeconfig --region ${var.region_code} --name ${var.eks_cluster.cluster_name}

    ### k9s 설치
    ##############################
    curl -LO https://github.com/derailed/k9s/releases/download/v0.40.7/k9s_Linux_amd64.tar.gz
    tar -xvf k9s_Linux_amd64.tar.gz

    sudo mkdir -p ~/.local/bin
    sudo mv ./k9s ~/.local/bin && chmod +x ~/.local/bin/k9s

    echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

    ### Helm 3 설치
    ##############################
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
  
    ### eksctl 설치
    ##############################
    # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH

    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm -f eksctl_$PLATFORM.tar.gz 

    sudo mv /tmp/eksctl /usr/local/bin

    set +u
    source ~/.bashrc
    set -u
    mkdir git && cd git && git clone https://github.com/PYJ-zero/youngjin_oss.git

  EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
