module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role       = true
  role_requires_mfa = false

  role_name = "${local.prefix}-ecs-task-execution-role"

  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
  ]
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role       = true
  role_requires_mfa = false

  role_name = "${local.prefix}-ecs-task-role"

  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    # todo
  ]
}

# ECS ブルーグリーンデプロイのために、ALB リスナー設定を変更するための IAM ロール
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AmazonECSInfrastructureRolePolicyForLoadBalancers.html
module "ecs_infrastructure_role_for_alb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role       = true
  role_requires_mfa = false

  role_name = "${local.prefix}-ecs-infrastructure-role-for-alb"

  trusted_role_services   = ["ecs.amazonaws.com"]
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"]
}
