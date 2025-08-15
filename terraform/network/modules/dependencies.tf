data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# --- vpc
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
