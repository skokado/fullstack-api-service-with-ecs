module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"

  domain_name = "fsas.${var.zone_name}"
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"

  wait_for_validation = true
}
