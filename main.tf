resource "aws_lightsail_key_pair" "this" {
  name = var.keypair_name
}

resource "aws_lightsail_instance" "this" {
  for_each = local.lightsail_instances

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

resource "aws_lightsail_instance_public_ports" "this" {
  for_each = aws_lightsail_instance.this

  instance_name = each.value.name

  dynamic "port_info" {
    for_each = var.default_ports_open_lightsail_instances
    content {
      from_port = port_info.value.from_port
      to_port   = port_info.value.to_port
      protocol  = port_info.value.protocol
      cidrs     = port_info.value.cidrs
    }
  }
}