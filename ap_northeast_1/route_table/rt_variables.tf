variable "vpc_id" {
  description = "라우팅 테이블에 연결할 VPC ID"
  type        = string
}

variable "igw_id" {
  description = "생성된 Internet Gateway ID"
  type        = any
}

variable "nat" {
  description = "생성된 NAT 게이트웨이 목록"
  type        = list(any)
}

variable "subnets" {
  description = "생성된 서브넷 목록"
  type        = any
}

variable "project_name" {
  description = "Project Name"
  type        = string
}