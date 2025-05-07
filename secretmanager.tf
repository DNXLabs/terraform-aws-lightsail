resource "aws_secretsmanager_secret" "this" {
  name                    = "keypair-lightsail-${var.instance_name_prefix}"
  description             = "The secret for the lightsail instances"
  recovery_window_in_days = var.secret_manager_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = aws_lightsail_key_pair.this.private_key
}