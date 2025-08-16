resource "aws_route53_record" "app" {
  depends_on = [module.alb]

  zone_id = data.aws_route53_zone.this.id
  name    = "fsas.${var.zone_name}"

  type = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = false
  }
}
