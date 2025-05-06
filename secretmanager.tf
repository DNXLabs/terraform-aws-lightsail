resource "aws_secretsmanager_secret" "this" {
  name                    = var.instance_secretsmanager_name
  description             = "The secret for the lightsail instances"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = aws_lightsail_key_pair.this.private_key
}