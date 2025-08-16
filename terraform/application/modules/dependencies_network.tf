data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    region = "ap-northeast-1"
    bucket = "fullstack-api-service-tfstate-dev"
    key    = "network.tfstate"
  }
}

# ref.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc.vpc_id]
  }
  filter {
    name   = "subnet-id"
    values = [for subnet_id in data.terraform_remote_state.network.outputs.vpc.public_subnets : subnet_id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc.vpc_id]
  }
  filter {
    name   = "subnet-id"
    values = [for subnet_id in data.terraform_remote_state.network.outputs.vpc.private_subnets : subnet_id]
  }
}
