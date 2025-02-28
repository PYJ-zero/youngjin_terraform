variable "vpc_id" {
  description = "라우팅 테이블에 연결할 VPC ID"
  type        = string
}

variable "subnets" {
  description = "생성된 서브넷 목록"
  type        = any
}

variable "project_name" {
  description = "Project Name"
  type        = string
}