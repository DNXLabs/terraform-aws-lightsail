locals {
  selected_database      = var.use_external_db ? values(aws_lightsail_database.this)[0] : null
}