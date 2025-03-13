// 보안 그룹 생성
resource "aws_security_group" "bastion_sg" {
  vpc_id      = var.vpc_id
  name        = local.bastion_sg_name
  description = local.bastion_sg_desc

  tags = {
    Name   = local.bastion_sg_name
    t_addr = "${path.module}/bastion.sg.tf"
  }
  lifecycle {
    ignore_changes = [
      tags["CreateDate"],
    ]
  }
}

### 아웃바운드
############
resource "aws_security_group_rule" "bastion_sg_rule_egress_0" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "sg for bastion ${local.description_suffix}"
  lifecycle {
    ignore_changes = [
      # description,
    ]
  }
}
