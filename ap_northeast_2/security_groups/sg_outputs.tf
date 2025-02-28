output "security_groups" {
  value = {
    redis_sg  = aws_security_group.redis_sg
  }
}