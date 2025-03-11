### 백엔드 지정, terraform cloud 사용시 필요없음###
###########################################################

# terraform {
#   backend "s3" {
#     # bucket = "{your_bucket_name}"
#     key    = "testtf"
#     region = "ap-south-1"
#   }
# }
terraform { 
  cloud { 
    
    organization = {your-org-name}

    workspaces { 
      name = {your-workspace-name}
    } 
  } 
}