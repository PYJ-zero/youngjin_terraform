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
  filter {
    name   = "architecture"
    values = ["x86_64"]
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
  # set -e 제거, 대신 -u와 -o pipefail만 사용
  set -uo pipefail

  LOG_FILE="/root/user_data.log"
  success_list=()
  fail_list=()

  # 명령어를 실행하면서 로그를 남기고 성공/실패를 배열에 저장
  run_command() {
    local cmd="$*"
    echo "---------------------------------------------------" | tee -a $LOG_FILE
    echo "[INFO] Running: $cmd" | tee -a $LOG_FILE
    eval "$cmd" >> $LOG_FILE 2>&1
    if [ $? -eq 0 ]; then
      echo "[SUCCESS] $cmd" | tee -a $LOG_FILE
      success_list+=("$cmd")
    else
      echo "[FAILURE] $cmd" | tee -a $LOG_FILE
      fail_list+=("$cmd")
    fi
  }

  # 예시: yum 업데이트
  run_command "yum update -y"
  run_command "yum install -y awscli vim git"

  # kubectl 설치
  run_command "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl"
  run_command "chmod +x ./kubectl"
  run_command "mkdir -p /root/bin && cp ./kubectl /root/bin/kubectl && export PATH=/root/bin:\$PATH"
  run_command "echo 'export PATH=/root/bin:\$PATH' >> /root/.bashrc"

  # kubeconfig 업데이트
  run_command "aws eks update-kubeconfig --region ${var.region_code} --name ${var.eks_cluster.cluster_name}"

  # k9s 설치
  run_command "curl -LO https://github.com/derailed/k9s/releases/download/v0.40.7/k9s_Linux_amd64.tar.gz"
  run_command "tar -xvf k9s_Linux_amd64.tar.gz"
  run_command "mkdir -p /root/.local/bin && mv ./k9s /root/.local/bin && chmod +x /root/.local/bin/k9s"
  run_command "rm -f k9s_Linux_amd64.tar.gz"
  run_command "echo 'export PATH=\$PATH:/root/.local/bin' >> /root/.bashrc"

  # helm 설치
  run_command "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
  run_command "chmod 700 get_helm.sh"
  run_command "./get_helm.sh"

  # eksctl 설치
  run_command "ARCH=amd64 && PLATFORM=\$(uname -s)_\$ARCH"
  run_command "curl -sLO https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_\$PLATFORM.tar.gz"
  run_command "curl -sL https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt | grep \$PLATFORM | sha256sum --check"
  run_command "tar -xzf eksctl_\$PLATFORM.tar.gz -C /tmp && rm -f eksctl_\$PLATFORM.tar.gz"
  run_command "mv /tmp/eksctl /usr/local/bin"

  # git clone
  run_command "mkdir /root/git && cd /root/git && git clone https://github.com/PYJ-zero/youngjin_oss.git"

  # velero 설치
  run_command "curl -L https://github.com/vmware-tanzu/velero/releases/download/v1.15.2/velero-v1.15.2-linux-amd64.tar.gz -o /tmp/velero.tar.gz"
  run_command "tar -xzvf /tmp/velero.tar.gz -C /tmp && rm -f /tmp/velero.tar.gz"
  run_command "mv /tmp/velero-v1.15.2-linux-amd64/velero /usr/local/bin/"
  run_command "chmod +x /usr/local/bin/velero"

  # credentials-velero 파일 생성
  run_command "cat <<CRED > /root/credentials-velero
  [default]
  aws_access_key_id=${var.iam_users.velero_user.id}
  aws_secret_access_key=${var.iam_users.velero_user.secret}
  CRED
  "

  # velero install
  run_command "velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.11.1 \
    --bucket ${var.s3_list.velero_bucket.id} \
    --backup-location-config region=${var.region_code} \
    --secret-file /root/credentials-velero \
    --snapshot-location-config region=${var.region_code}"

  # 스크립트 마지막에 요약 로그 출력
  echo "---------------------------------------------------" | tee -a $LOG_FILE
  echo "[INFO] Summary of commands" | tee -a $LOG_FILE

  if [ $${#success_list[@]} -gt 0 ]; then
    echo "[INFO] Succeeded: $${success_list[*]}" | tee -a $LOG_FILE
  fi

  if [ $${#fail_list[@]} -gt 0 ]; then
    echo "[INFO] Failed: $${fail_list[*]}" | tee -a $LOG_FILE
  fi
  source /root/.bashrc
  EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
