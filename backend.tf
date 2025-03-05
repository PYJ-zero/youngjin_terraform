### 백엔드 지정, terraform cloud 사용시 필요없음###
###########################################################

terraform {
  backend "s3" {
    bucket = "{put-your-bucket-name}"
    key    = "testtf"
    region = "ap-northeast-1"
  }
}
