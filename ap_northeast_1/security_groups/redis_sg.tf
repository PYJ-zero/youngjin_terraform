locals {
  redis_sg_name  = "${var.project_name}-redis-sg"
  redis_sg_desc  = local.redis_sg_name
}

// 보안 그룹 생성
resource "aws_security_group" "redis_sg" {
  vpc_id      = var.vpc_id
  name        = local.redis_sg_name
  description = local.redis_sg_desc

  tags        = {
    Name       = local.redis_sg_name
    t_addr     = "${path.module}/redis_sg.tf"
  }
  lifecycle {
    ignore_changes = [
      tags["CreateDate"],
    ]
  }
}

### 인바운드
############

resource "aws_security_group_rule" "redis_sg_rule_ingress_0" {
  security_group_id = aws_security_group.redis_sg.id
  type              = "ingress"
  protocol    = "tcp"
  from_port   = 6379
  to_port     = 6379
  cidr_blocks = ["150.0.0.0/16"]
  description = "redis sg"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}

resource "aws_security_group_rule" "redis_sg_rule_egress_0" {
  security_group_id = aws_security_group.redis_sg.id
  type              = "egress"
  protocol    = "tcp"
  from_port   = 3306
  to_port     = 3306
  cidr_blocks = ["150.0.0.0/16"]
  description = "redis sg to rds"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}