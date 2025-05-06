resource "aws_lightsail_instance" "this" {
  for_each = var.lightsail_instances

  name              = each.value.name
  availability_zone = each.value.availability_zone
  blueprint_id      = each.value.blueprint_id
  bundle_id         = each.value.bundle_id
  ip_address_type   = each.value.ip_address_type
  key_pair_name     = aws_lightsail_key_pair.this.name

  user_data = var.use_external_db ? templatefile("./scripts/user_data.sh.tpl", {
    db_name     = local.selected_database.master_database_name
    db_user     = local.selected_database.master_username
    db_password = local.selected_database.master_password
    db_host     = local.selected_database.master_endpoint_address
  }) : null

  tags = {
    Name = each.value.name
  }
}

resource "aws_lightsail_key_pair" "this" {
  name = var.keypair_name
}

resource "aws_lightsail_database" "this" {
  for_each = var.use_external_db ? var.lightsail_database : {}

  relational_database_name = each.value.relational_database_name
  availability_zone        = each.value.availability_zone
  master_database_name     = each.value.master_database_name
  master_password          = random_password.this[0].result
  master_username          = each.value.master_username
  blueprint_id             = each.value.blueprint_id
  bundle_id                = each.value.bundle_id
  skip_final_snapshot      = each.value.skip_final_snapshot

  tags = {
    Name = each.value.relational_database_name
  }
}

resource "aws_lightsail_lb" "this" {
  name              = var.lb_name
  health_check_path = "/"
  instance_port     = var.instance_port
  ip_address_type   = "ipv4"

}

resource "aws_lightsail_lb_attachment" "this" {
  for_each = aws_lightsail_instance.this

  lb_name       = aws_lightsail_lb.this.name
  instance_name = each.value.name
}

resource "aws_lightsail_lb_certificate" "this" {
  count = var.domain_name != "" ? 1 : 0

  name        = replace("crt-${var.domain_name}", ".", "-")
  lb_name     = aws_lightsail_lb.this.name
  domain_name = var.domain_name
}

resource "aws_lightsail_lb_certificate_attachment" "this" {
  count = var.domain_name != "" && var.attach_certificate_to_lb ? 1 : 0

  lb_name          = aws_lightsail_lb.this.name
  certificate_name = aws_lightsail_lb_certificate.this[0].name
}

resource "aws_lightsail_instance_public_ports" "this" {
  for_each = aws_lightsail_instance.this

  instance_name = each.value.name

  dynamic "port_info" {
    for_each = var.default_ports
    content {
      from_port = port_info.value.from_port
      to_port   = port_info.value.to_port
      protocol  = port_info.value.protocol
      cidrs     = port_info.value.cidrs
    }
  }
}

