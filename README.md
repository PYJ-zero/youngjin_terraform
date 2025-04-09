# youngjin_terraform

Terraform을 이용해 AWS 기반 인프라를 코드로 정의하고, 다양한 컴포넌트를 모듈화하여 관리하는 예제 프로젝트입니다.  
EKS, EC2, RDS, Redis, S3, Karpenter, ELB, NAT, VPC 등 주요 리소스를 포함하며, 구성에 따라 부분적 활성화/비활성화가 가능합니다.

---

## 📦 디렉토리 구조

```
.
├── main.tf                   # 전체 구성 진입점
├── aws.tf                   # AWS Provider 정의
├── backend.tf               # Terraform Cloud Backend 정의
├── variables.tf             # 전역 변수 정의
├── ap_south_1/              # 뭄바이 리전 리소스 구성
│   ├── eks/                 # EKS 클러스터, Karpenter, 노드그룹
│   ├── ec2/                 # Bastion EC2
│   ├── rds/                 # Aurora MySQL RDS
│   ├── redis/               # Redis Cluster
│   ├── efs/                 # Elastic File System
│   ├── s3/                  # 일반 버킷 + Velero 백업용 S3
│   ├── iam/                 # 각종 IAM Role/User/Profile
│   ├── security_groups/     # Redis, Bastion, ALB용 SG
│   ├── elb/                 # ALB (Application Load Balancer)
│   ├── igw/, nat/, eip/     # 네트워크 연결 리소스
│   ├── subnets/, route_table/  # 서브넷, 라우팅 테이블
│   └── endpoint/            # (옵션) VPC Endpoint
```

---

## ⚙️ 주요 기능

- 모듈화된 AWS 인프라 구성: VPC, 서브넷, NAT, IGW, EIP, 보안 그룹 등
- EKS + Karpenter:
  - EKS 클러스터 생성
  - Karpenter를 통한 스팟 기반 워커노드 자동 증설 및 제거
- EC2 Bastion 서버: SSM 연결을 위한 역할 자동 생성
- RDS, Redis, EFS: 주석 해제 후 손쉽게 활성화 가능
- S3 + Velero 백업 구조
- Terraform Cloud 연동
- Security Group 분리 관리: Redis/ALB/Bastion 별 SG 모듈 구성

---

## 🚀 시작하기

### 1. 요구사항

- Terraform CLI 1.3 이상
- AWS 계정 & 적절한 IAM 권한
- Terraform Cloud 계정 (백엔드 사용 시)

### 2. 초기 설정

```bash
git clone https://github.com/PYJ-zero/youngjin_terraform.git
cd youngjin_terraform
terraform init
```

- `variables.tf` 또는 `.tfvars`에서 `project_name`, `region_code` 설정
- `backend.tf`에 본인의 Terraform Cloud org/workspace 설정

---

## ☁️ 구성 활성화 팁

- RDS, Redis, EFS, Endpoint, ELB 등은 기본적으로 주석 처리되어 있음
- `ap_south_1/ap_south_1_main.tf` 내 주석을 해제하고 필요 변수 채워서 활성화 가능
- 각 모듈은 `source = ./<모듈 디렉토리>` 형태로 구조화되어 있음

---

---

## ⚠️ 운영 시 참고사항 및 기술적 메모

이 섹션은 이 프로젝트의 작성자가 Terraform 코드 작성 당시 고려한 **설정 의도, 보안 주의사항, 구성의 맥락** 등을 기억 보존 및 유지보수 목적으로 정리한 내용입니다.

### 🧱 모듈 사용 시 기술적 주의사항

#### EKS & Karpenter

- `karpenter-node-role`은 수동으로 직접 정의하며, 다음과 같은 기본 정책을 명시적으로 붙여 사용합니다:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonSSMManagedInstanceCore`
  - ➤ 나중에 EBS, S3, Spot 인터럽트 등 연동 시 `ec2:CreateTags`, `ec2:DescribeTags`, `autoscaling:*` 권한이 추가적으로 필요할 수 있습니다.

- Karpenter의 IAM 역할은 `IRSA` 방식이 아닌 EC2에 직접 붙는 방식으로 구성되어 있습니다.
  - ➤ IRSA로 전환할 경우 trust policy 및 oidc 설정을 수동으로 수정해야 합니다.

- `ttlSecondsAfterEmpty`, `consolidation` 같은 노드 자동 정리 설정은 현재 코드에 명시적으로 정의되어 있지 않습니다.
  - ➤ Helm Chart의 `values.yaml`에서 관리하고 있을 가능성 높으며, Terraform화가 필요할 수 있습니다.

#### Addons 설치

- EKS `vpc-cni`, `kube-proxy`, `coredns` 등은 Terraform으로 설치됩니다.
  - ➤ Addon 버전 고정 필수. 추후 EKS 자체 자동 업데이트와 충돌을 피하려면 lifecycle 제어를 고려해야 합니다.
  - ➤ IRSA를 사용하는 Addon이 있다면, 그에 맞는 IAM Role 정의가 필요합니다 (`trust_relationship`, `eks.amazonaws.com/serviceaccount` 사용).

---

### 🔐 보안 관련 주의사항

#### Security Groups

- `alb_sg`는 기본적으로 `0.0.0.0/0` IP에 `80`, `443` 포트를 오픈합니다.
  - ➤ 개발 환경용으로는 허용되나, 운영에서는 WAF 연동 혹은 CIDR 제한 권장

- Redis SG는 `150.0.0.0/16`에 열려 있음:
  - ➤ 내부망일 가능성이 높으므로, CIDR 설명 주석을 명시하거나 README에 기록하는 것이 좋습니다.

#### IAM Roles

- `ssm_role`에는 `AdministratorAccess`가 붙어 있음:
  - ➤ Bastion 서버를 위한 긴급 접근용이라도 최소 권한 정책으로 재설계 필요

- Node용 IAM Roles에는 기본적으로 EC2 실행 권한만 존재하며, `tagging` 권한 없음:
  - ➤ Karpenter가 EC2, ENI, EBS 리소스를 태깅/정리할 수 있도록 추가 권한 부여 권장

---

### 🛠️ 유지보수용 메모

- `iam_role_karpenterNode.tf_` ← 파일명 끝에 `_`가 붙은 이유는 apply 충돌 방지나 수동 백업 의도, 사용 여부 확인 후 정리 필요

- ALB 모듈 내의 `listener`, `target-group`, `listener-rule`이 주석 처리돼 있음:
  - ➤ 프로젝트 초기엔 ALB 테스트만 목적이었고, 추후 `/app/*` 경로 기반 라우팅 또는 마이크로서비스 도입을 예상했던 구조

---

### ☁️ 클라우드 구성 및 비용 관련

- NAT Gateway 다중화 구성 (변수: `nat_eip`, `nat_subnets`)을 지원함:
  - ➤ 가용성을 높이기 위한 설계이나, NAT 비용이 증가하므로 프로덕션 외 환경에서는 단일 NAT로 변경 가능

- RDS, Redis, EFS, Endpoint, ELB 등은 모두 `ap_south_1_main.tf`에서 주석 처리 상태로 비활성화됨:
  - ➤ 필요 시 주석 해제 + `.tfvars` 입력만으로 쉽게 활성화 가능하도록 설계되어 있음

---

## ✅ 유지관리자를 위한 기억 트리거

> 이 프로젝트는 여러 리소스를 모듈화했으며, 생성 순서, 종속성, 권한 체계에 대해 정교하게 설계되어 있습니다.  
> 해당 문서는 유지보수자 또는 작성자인 내가 수개월 후에도 당시 설계를 기억할 수 있도록 작성된 참조용 안내서입니다.

## 👤 작성자

- Youngjin Park  
- GitHub: [PYJ-zero](https://github.com/PYJ-zero)