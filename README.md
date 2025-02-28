# youngjin_terraform

이 저장소는 Terraform을 사용하여 AWS 인프라를 코드로 관리하기 위한 예제 프로젝트입니다.
module을 삭제한 상태이기에 실제 작동시 모듈 설치가 동반됩니다.

## 주요 파일 및 디렉토리

- **main.tf**: AWS 리소스를 정의하는 메인 구성 파일.
- **variables.tf**: 프로젝트에서 사용되는 변수들을 선언하는 파일.
- **backend.tf**: Terraform 상태 파일의 백엔드를 설정하는 파일.
- **aws.tf**: AWS 프로바이더를 설정하는 파일.
- **ap_northeast_2/**: 서울 리전에 대한 환경별 구성 디렉토리.

## 시작하기

### 사전 요구 사항

- Terraform이 설치되어 있어야 합니다. [Terraform 설치 가이드](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)를 참고하세요.
- AWS 계정 및 적절한 IAM 권한이 필요합니다.

### 초기 설정

1. 저장소를 클론합니다:
   ```bash
   git clone https://github.com/PYJ-zero/youngjin_terraform.git
   cd youngjin_terraform
