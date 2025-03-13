// 보안 그룹 생성
resource "aws_security_group" "alb_sg" {
  vpc_id      = var.vpc_id
  name        = local.alb_sg_name
  description = local.alb_sg_desc

  tags = {
    Name   = local.alb_sg_name
    t_addr = "${path.module}/alb.sg.tf"
  }
  lifecycle {
    ignore_changes = [
      tags["CreateDate"],
    ]
  }
}

### 인바운드
############
resource "aws_security_group_rule" "alb_sg_rule_ingress_0" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "sg for alb ${local.description_suffix}"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}
resource "aws_security_group_rule" "alb_sg_rule_ingress_1" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "sg for alb ${local.description_suffix}"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}
### 아웃바운드
############
resource "aws_security_group_rule" "alb_sg_rule_egress_0" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["150.0.0.0/8"]
  description       = "sg for alb ${local.description_suffix}"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}

resource "aws_security_group_rule" "alb_sg_rule_egress_1" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["150.0.0.0/8"]
  description       = "sg for alb ${local.description_suffix}"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}
