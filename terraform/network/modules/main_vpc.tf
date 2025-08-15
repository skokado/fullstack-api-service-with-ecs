locals {
  public_subnet_cidrs  = [for i in range(var.number_of_azs) : cidrsubnet(var.vpc_cidr, 10, i + 1)]
  private_subnet_cidrs = [for i in range(var.number_of_azs) : cidrsubnet(var.vpc_cidr, 10, length(local.public_subnet_cidrs) + 1 + 1)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.prefix
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = false
}
