module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${local.prefix}-alb-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc.vpc_id

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Blue/Green test traffic"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${local.prefix}-ecs-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc.vpc_id

  egress_rules = ["all-all"]

  ingress_with_source_security_group_id = [
    {
      description              = "Allow from ALB"
      from_port                = "8000"
      to_port                  = "8000"
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
  ]
}
