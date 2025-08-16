resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${local.prefix}-app"
  retention_in_days = 7
}
