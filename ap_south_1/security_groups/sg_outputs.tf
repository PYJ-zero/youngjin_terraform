output "security_groups" {
  value = {
    redis_sg   = aws_security_group.redis_sg
    bastion_sg = aws_security_group.bastion_sg
    alb_sg     = aws_security_group.alb_sg
  }
}
