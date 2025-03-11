resource "aws_eip" "nat_eips" {
  count      = length(var.nat_subnets)
  domain     = "vpc"
  
   tags = {
      Name     = "${var.project_name}-nat-${substr(element(var.nat_subnets.*.availability_zone, count.index),14,1)}-eip"
      nat      = "true"
  }
}