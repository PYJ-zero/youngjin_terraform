terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }
}

### 환경에 따라 자격 증명 변경 필요###
############################################
# provider "aws" {
#     region = "ap-south-1"
#   assume_role {  
#     # role_arn     = "{your_role_arn}"
#   }
# }

provider "aws" { 
 region     = "ap-south-1"
}

