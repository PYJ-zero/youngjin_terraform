terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

  }
}

### 환경에 따라 자격 증명 변경 필요###
############################################
provider "aws" {
    region = "ap-northeast-1"
  assume_role {
    role_arn     = "{put_your_terraform_role_arn}"
    # session_name = ""
  }
}

#provider "aws" {
#  access_key = "{access_key}"
#  secret_key = "{secret_key}"
#  region     = "ap-northeast-2"
#}

