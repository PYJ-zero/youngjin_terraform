terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.1.2"
    }
  }
}

### 환경에 따라 자격 증명 변경 필요###
############################################
# provider "aws" {
#     region = "ap-northeast-2"
#   assume_role {
#     role_arn     = "{role_arn}"
#     session_name = "pyj-terraform-role-c"
#   }
# }

provider "aws" {
  access_key = "{access_key}"
  secret_key = "{secret_key}"
  region     = "ap-northeast-2"
}

