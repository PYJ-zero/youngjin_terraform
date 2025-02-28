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