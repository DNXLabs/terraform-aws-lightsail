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
