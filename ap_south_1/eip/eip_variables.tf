variable "vpc_id" {
  description = "인터넷 게이트웨이에 연결할 VPC ID"
  type        = string
}

variable "nat_subnets" {
  description = "NAT가 적용될 서브넷 목록"
  type        = any
}
variable "project_name" {
  description = "Project Name"
  type        = string
}
