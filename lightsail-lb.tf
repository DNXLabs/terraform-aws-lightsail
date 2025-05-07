
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
