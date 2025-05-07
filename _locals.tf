locals {
  selected_database = var.use_external_db ? values(aws_lightsail_database.this)[0] : null
  domain_validation = try(tolist(aws_lightsail_lb_certificate.this[0].domain_validation_records)[0],null)

  lightsail_instances = {
    for i in range(var.instance_count) :
    format("instance-%02d", i + 1) => {
      name              = format("%s-%02d", var.instance_name_prefix, i + 1)
      availability_zone = var.instance_config.availability_zone
      blueprint_id      = var.instance_config.blueprint_id
      bundle_id         = var.instance_config.bundle_id
      ip_address_type   = var.instance_config.ip_address_type
    }
  }
}