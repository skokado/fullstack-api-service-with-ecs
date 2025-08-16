module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 6.2.0"

  name = local.prefix

  # default_capacity_provider_strategy = {
  #   FARGATE = {
  #     weight = 1
  #   }
  #   FARGATE_SPOT = {
  #     base   = length(data.aws_subnets.private.ids)
  #     weight = 1
  #   }
  # }
}
