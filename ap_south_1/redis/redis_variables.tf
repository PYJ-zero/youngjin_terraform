variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "db_subnet" {
  description = "DB 서브넷 그룹"
  type        = any
}

variable "region_code" {
  description = "Region code"
  type        = string
}

variable "security_groups" {
  type = any
}
