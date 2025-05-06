resource "random_password" "this" {
  count            = var.use_external_db ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#-_=+^&*.,?"
}

resource "aws_ssm_parameter" "this" {
  count       = var.use_external_db ? 1 : 0
  name        = "/param/aws/lightsail/${aws_lightsail_database.this[0].relational_database_name}"
  description = "The password for the lightsail databases"
  type        = "SecureString"
  value       = random_password.this[0].result
}