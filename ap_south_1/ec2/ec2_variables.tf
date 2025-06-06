variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "subnets" {
  description = "생성된 서브넷 목록"
  type        = any
}

variable "region_code" {
  description = "Region Code"
  type        = string
}

variable "security_groups" {
  type = any
}

variable "iam_ssm_profile" {
  type = any
}

variable "eks_cluster" {
  type = any
}

variable "iam_users" {
  type = any
}

variable "s3_list" {
  type = any
  
}
