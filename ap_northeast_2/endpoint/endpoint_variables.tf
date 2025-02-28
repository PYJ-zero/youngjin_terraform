variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "route_table" {
  description = "Route table list"
  type        = any
}