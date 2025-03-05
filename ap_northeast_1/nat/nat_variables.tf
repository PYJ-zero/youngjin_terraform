variable "nat_subnets" {
  description = "NAT가 적용될 서브넷 목록"
  type        = any
}

variable "nat_eip" {
  description = "NAT가 적용될 eip 목록"
  type        = any
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "project_name" {
  description = "Project Name"
  type        = string
}