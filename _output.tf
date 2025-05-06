output "lightsail_instance_arn" {
  description = "ARN of the Lightsail instances"
  value       = { for k, v in aws_lightsail_instance.this : k => v.arn }
}

output "instance_public_ips" {
  description = "Public IPs of the Lightsail instances"
  value       = { for k, v in aws_lightsail_instance.this : k => v.public_ip_address }
}

output "lightsail_database_arn" {
  description = "ARN of the Lightsail database"
  value       = var.use_external_db ? { for k, v in aws_lightsail_database.this : k => v.arn } : null
}

output "database_dns" {
  description = "DNS of the Lightsail database"
  value       = var.use_external_db ? { for k, v in aws_lightsail_database.this : k => v.master_endpoint_address } : null
}

output "lightsail_load_balancer_arn" {
  description = "ARN of the Lightsail Load Balancer"
  value       = aws_lightsail_lb.this.arn
}

output "load_balancer_dns" {
  description = "DNS of the Lightsail Load Balancer"
  value       = aws_lightsail_lb.this.dns_name
}

output "domain_validation_dns" {
  value = try(aws_lightsail_lb_certificate.this[0].domain_validation_records[*], null)
}
