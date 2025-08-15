terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Terraform  = "true"
      Repository = "skokado/fullstack-api-service-with-ecs"
      Path       = "terraform/network"
    }
  }
}
