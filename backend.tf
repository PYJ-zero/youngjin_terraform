### 백엔드 지정, terraform cloud 사용시 필요없음###
###########################################################

terraform {
  backend "s3" {
    bucket = "{your-s3-name}"
    key    = "{tfstate-name}"
    region = "ap-northeast-2"
  }
}
