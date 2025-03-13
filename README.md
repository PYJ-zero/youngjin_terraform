# youngjin_terraform

이 저장소는 Terraform을 사용하여 AWS 인프라를 코드로 관리하기 위한 예제 프로젝트입니다.
module을 삭제한 상태이기에 실제 작동시 모듈 설치가 동반됩니다.

## 기능

1. EKS Cluster와 연동할 수 있도록 모든 설정이 자동화 되어 있습니다.

- EKS 접근용 Bastion 생성 및 보안 그룹 연결
- Bastion 내 kubectl 및 eks config 설정
- EKS configMap 내 aws-auth 설정

## 특이사항

테스트 용도 목적으로 비용이 저렴한 뭄바이(ap-south-1)을 기준으로 리소스를 생성합니다.

## 주요 파일 및 디렉토리

- **main.tf**: AWS 리소스를 정의하는 메인 구성 파일.
- **variables.tf**: 프로젝트에서 사용되는 변수들을 선언하는 파일.
- **backend.tf**: Terraform 상태 파일의 백엔드를 설정하는 파일.
- **aws.tf**: AWS 프로바이더를 설정하는 파일.
- **ap_south_1/**: 서울 리전에 대한 환경별 구성 디렉토리.

## 시작하기

### 사전 요구 사항

- terraform backend로 사용할 s3는 수동으로 사전 생성해야 합니다.
- Terraform이 설치되어 있어야 합니다. [Terraform 설치 가이드](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)를 참고하세요.
- AWS 계정 및 적절한 IAM 권한이 필요합니다.

### 초기 설정

1. 저장소를 클론합니다:

   ```bash
   git clone https://github.com/PYJ-zero/youngjin_terraform.git
   cd youngjin_terraform

2. IAM User 생성
   Terraform 사용을 위해 IAM User 및 Access Key를 생성합니다.

3. Terraform Cloud 연동
   <https://developer.hashicorp.com/terraform/cli/cloud/settings>
   Backend는 Terraform Cloud를 사용하며 워크스페이스 및 프로젝트를 생성합니다.
   Variables에 AWS Access Key 및 Secret Key를 등록하여 사용합니다.

4. Backend 변경
   backend.tf에서 terraform cloud의 org 및 workspace의 이름을 넣어줍니다.
   variables.tf의 project_name을 변경해 줍니다.

5. 테라폼 초기화

   ```bash
   terraform init
