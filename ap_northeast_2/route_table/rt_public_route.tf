resource "aws_route_table" "public_rtb" {
  vpc_id = var.vpc_id
    tags = {
    Name = "${var.project_name}-rtb-pub"
  }
}
  
resource "aws_route" "public_rtb_igw_route" {
  route_table_id     = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = var.igw_id
}

resource "aws_route_table_association" "public_subnet" {
  count = length(var.subnets.public_pub_subnets)
  subnet_id      = element(var.subnets.public_pub_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rtb.id
}