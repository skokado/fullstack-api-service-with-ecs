module "this" {
  source = "../../modules"

  env = "dev"

  vpc_cidr      = "10.0.0.0/16"
  number_of_azs = 2
}
