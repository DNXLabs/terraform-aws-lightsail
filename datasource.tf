data "aws_route53_zone" "this" {
  count        = var.create_dns_record && var.domain_name != "" && var.hosted_zone_id == "" ? 1 : 0
}