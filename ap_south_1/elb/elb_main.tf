# ALB 생성
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"   # 사용 중인 모듈 버전에 맞게 수정

  name                = "${var.project_name}-alb"
  load_balancer_type  = "application"
  internal            = false
  subnets             = [for subnet in var.subnets.public_pub_subnets.id : subnet.id]     # 퍼블릭 서브넷 ID 목록
  security_groups     = [var.security_groups.alb_sg.id]         # ALB에 적용할 보안 그룹 ID

}

# # ALB 리스너 생성 (HTTP:80)
# module "alb_listener" {
#   source  = "terraform-aws-modules/alb/aws//modules/listener"
#   version = "~> 8.0"

#   load_balancer_arn = module.alb.this_lb_arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action = {
#     type = "fixed-response"
#     fixed_response = {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#     }
#   }
# }

# # (옵션) ALB 타겟 그룹 생성 예시
# module "alb_target_group" {
#   source  = "terraform-aws-modules/alb/aws//modules/target-group"
#   version = "~> 8.0"

#   name     = "${var.project_name}-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id

#   health_check = {
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     timeout             = 5
#     interval            = 30
#     path                = "/"
#     matcher             = "200-299"
#   }

#   tags = {
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# # (옵션) ALB 리스너 규칙을 통해 타겟 그룹으로 트래픽 전달
# module "alb_listener_rule" {
#   source  = "terraform-aws-modules/alb/aws//modules/listener-rule"
#   version = "~> 8.0"

#   listener_arn = module.alb_listener.this_listener_arn
#   priority     = 100

#   actions = [
#     {
#       type             = "forward"
#       target_group_arn = module.alb_target_group.this_target_group_arn
#     }
#   ]

#   conditions = [
#     {
#       field  = "path-pattern"
#       values = ["/app/*"]
#     }
#   ]
# }