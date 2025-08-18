# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#example-using-runtime_platform-and-fargate
resource "aws_ecs_task_definition" "this" {
  family = local.prefix

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
  task_role_arn      = module.ecs_task_role.iam_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = module.ecr_app.repository_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        },
      ]
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval    = 30
        timeout     = 3
        retries     = 2
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_app.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

module "ecs_service_app" {
  # https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 6.2.0"

  cluster_arn = module.ecs_cluster.arn
  name        = "app"

  desired_count = length(data.aws_subnets.private.ids)
  cpu           = 256
  memory        = 512

  enable_execute_command = true

  subnet_ids = data.aws_subnets.private.ids

  create_security_group = false
  security_group_ids    = [module.ecs_sg.security_group_id]

  create_task_definition = false
  task_definition_arn    = aws_ecs_task_definition.this.arn

  create_task_exec_iam_role = false
  create_tasks_iam_role     = false

  capacity_provider_strategy = {
    FARGATE_SPOT = {
      base              = length(data.aws_subnets.private.ids)
      weight            = 1
      capacity_provider = "FARGATE_SPOT"
    }
    FARGATE = {
      weight            = 1
      capacity_provider = "FARGATE"
    }
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_configuration
  deployment_configuration = {
    strategy             = "BLUE_GREEN"
    bake_time_in_minutes = 1
  }

  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.app_0.arn
      container_name   = "app"
      container_port   = 8000

      # for BLUE_GREEN deployment
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#advanced_configuration
      advanced_configuration = {
        alternate_target_group_arn = aws_lb_target_group.app_1.arn
        role_arn                   = module.ecs_infrastructure_role_for_alb.iam_role_arn
        production_listener_rule   = data.external.lb_listener_app_production_default_rule.result.arn
        test_listener_rule         = data.external.lb_listener_app_test_traffic_default_rule.result.arn
      }
    }
  }
}
