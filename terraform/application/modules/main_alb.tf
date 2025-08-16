resource "aws_lb_target_group" "app_0" {
  name                 = "${local.prefix}-app-0"
  vpc_id               = data.terraform_remote_state.network.outputs.vpc.vpc_id
  target_type          = "ip"
  port                 = 8000
  protocol             = "HTTP"
  deregistration_delay = 300
  health_check {
    path    = "/health"
    timeout = "5"
  }
}
resource "aws_lb_target_group" "app_1" {
  name                 = "${local.prefix}-app-1"
  vpc_id               = data.terraform_remote_state.network.outputs.vpc.vpc_id
  target_type          = "ip"
  port                 = 8000
  protocol             = "HTTP"
  deregistration_delay = 300
  health_check {
    path    = "/health"
    timeout = "5"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = "${local.prefix}-app-alb"
  vpc_id  = data.terraform_remote_state.network.outputs.vpc.vpc_id
  subnets = data.aws_subnets.public.ids

  create_security_group = false
  security_groups       = [module.alb_sg.security_group_id]

  load_balancer_type = "application"
}

resource "aws_lb_listener" "app_production" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_0.arn
  }

  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn,
    ]
  }
}

resource "aws_lb_listener" "app_test_traffic" {
  load_balancer_arn = module.alb.arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_1.arn
  }

  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn,
    ]
  }
}

# LB リスナーのデフォルトルール ARN を Terraform で上手く取得する方法がないため、かなり強引な対処法
data "external" "lb_listener_app_production_rule_arn" {
  program = ["bash", "-c", <<EOF
rule_arn=$(aws elbv2 describe-rules --listener-arn ${aws_lb_listener.app_production.arn} --query 'Rules[?IsDefault==`true`].RuleArn' --output text)
echo "{\"arn\":\"$rule_arn\"}"
EOF
  ]
}
data "external" "lb_listener_app_test_traffic_rule_arn" {
  program = ["bash", "-c", <<EOF
rule_arn=$(aws elbv2 describe-rules --listener-arn ${aws_lb_listener.app_test_traffic.arn} --query 'Rules[?IsDefault==`true`].RuleArn' --output text)
echo "{\"arn\":\"$rule_arn\"}"
EOF
  ]
}
