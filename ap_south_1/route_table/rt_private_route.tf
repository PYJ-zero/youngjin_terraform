resource "aws_route_table" "private_rtb" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project_name}-rtb-pri"
  }
}

resource "aws_route" "private_rtb_nat_route" {
  route_table_id         = aws_route_table.private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(var.nat.*.id, 0)
}

resource "aws_route_table_association" "private_subnet" {
  count          = length(var.subnets.private_pri_subnets)
  subnet_id      = element(concat(var.subnets.private_pri_subnets.*.id), count.index)
  route_table_id = aws_route_table.private_rtb.id
}
