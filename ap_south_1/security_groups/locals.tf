locals {
    bastion_sg_name  = "${var.project_name}-bastion-sg"
    bastion_sg_desc  = local.bastion_sg_name
    redis_sg_name  = "${var.project_name}-redis-sg"
    redis_sg_desc  = local.redis_sg_name
    alb_sg_name  = "${var.project_name}-alb-sg"
    alb_sg_desc  = local.redis_sg_name
    description_suffix = "by terraform"
}