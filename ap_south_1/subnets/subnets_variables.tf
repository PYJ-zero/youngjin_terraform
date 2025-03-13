variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "vpc_id" {
  description = "라우팅 테이블에 연결할 VPC ID"
  type        = string
}

variable "region_code" {
  description = "Region code"
  type        = string
}

variable "subnets" {
  description = "subnet_list"
  type        = any
}
