output "rtb_list" {
  value = {
    public_rtb      = [aws_route_table.public_rtb]
    private_pri_rtb = [aws_route_table.private_rtb]
    db_rtb          = [aws_route_table.db_rtb]
  }
}

output "public_rtb" {
  value = aws_route_table.public_rtb
}

output "private_rtb" {
  value = aws_route_table.private_rtb
}

output "db_rtb" {
  value = aws_route_table.db_rtb
}
