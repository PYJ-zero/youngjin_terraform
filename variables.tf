### 전체 코드에 사용될 변수 선언 ###

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "tf-dev-pyj"
}

variable "region_code" {
  description = "Region code"
  type        = string
  default     = "ap-south-1"
}
