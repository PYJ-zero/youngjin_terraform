### 백엔드 지정, terraform cloud 사용시 필요없음###
###########################################################

terraform {
  backend "s3" {
    bucket = "tf-dev-terraform-backend-tokyo-s3"
    key    = "testtf"
    region = "ap-northeast-1"
  }
}
