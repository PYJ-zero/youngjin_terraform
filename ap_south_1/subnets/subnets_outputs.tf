output "subnet_list" {
  value = {
    public_pub_subnets  = [aws_subnet.public_subnet_a, aws_subnet.public_subnet_c]
    private_pri_subnets = [aws_subnet.private_pri_subnet_a, aws_subnet.private_pri_subnet_c]
    private_pri_a_subnets = aws_subnet.private_pri_subnet_a
    private_pri_c_subnets = aws_subnet.private_pri_subnet_c
    private_nat_subnets = [aws_subnet.public_subnet_a]
    db_subnets          = [aws_subnet.db_subnet_a, aws_subnet.db_subnet_c]
    eks_subnets         = [aws_subnet.public_subnet_a, aws_subnet.public_subnet_c, aws_subnet.private_pri_subnet_a, aws_subnet.private_pri_subnet_c]
  }
}

output "db_subnet" {
  value = {
    db_subnet           = aws_db_subnet_group.db_subnet
    redis_subnet        = aws_elasticache_subnet_group.cache_subnet
  }
}