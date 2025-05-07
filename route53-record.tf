resource "aws_route53_record" "dns_loadbalancer_record" {
  count   = var.create_dns_record && var.domain_name != "" ? 1 : 0

  zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : data.aws_route53_zone.this[0].zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lightsail_lb.this.dns_name]
}

resource "aws_route53_record" "certificate_validation" {
  count = var.create_certificate_record && var.domain_name != "" ? 1 : 0

  zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : data.aws_route53_zone.this[0].zone_id
  name    = local.domain_validation.resource_record_name
  type    = local.domain_validation.resource_record_type
  ttl     = 300
  records = [local.domain_validation.resource_record_value]
}