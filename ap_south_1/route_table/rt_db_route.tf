resource "aws_route_table" "db_rtb" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project_name}-rtb-db"
  }
}

resource "aws_route_table_association" "db_subnet" {
  count          = length(var.subnets.db_subnets)
  subnet_id      = element(concat(var.subnets.db_subnets.*.id), count.index)
  route_table_id = aws_route_table.db_rtb.id
}
