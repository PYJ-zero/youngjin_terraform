resource "aws_nat_gateway" "nat" {
  count         = length(var.nat_eip)
  
  allocation_id = element(var.nat_eip.*.id, count.index)
  subnet_id  = element(var.nat_subnets.*.id, count.index)
  
  tags = {
      Name     = "${var.project_name}-nat"
  }
}