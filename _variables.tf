variable "use_external_db" {
  description = "Define if an external database Lightsail will be used"
  type        = bool
  default     = false
}

variable "attach_certificate_to_lb" {
  description = "Flag to control if a SSL certificate will be attached to the load balancer after domain validation"
  type        = bool
  default     = false
}

variable "create_dns_record" {
  type        = bool
  description = "Define if the DNS entry will be created in Route 53"
  default     = false
}

variable "create_certificate_record" {
  type        = bool
  description = "Define if the DNS entry will be created in Route 53 to validate the SSL certificate"
  default     = false
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of the hosted zone in Route53 (optional)"
  default     = ""
}

variable "snapthot_time" {
  type        = string
  description = "Time to take the snapshot"
  default     = ""
}

variable "enable_auto_snapshot" {
  type        = bool
  description = "Enable auto snapshot"
  default     = false
}


variable "default_ports_open_lightsail_instances" {
  description = "List of ports to open in the Lightsail instance and the correspondent IP ranges"
  type = list(object({
    from_port = number
    protocol  = string
    to_port   = number
    cidrs     = list(string)
  }))
  default = []
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
  default     = ""
}

variable "instance_port" {
  description = "Port of the instance"
  type        = number
  default     = 80
}

variable "keypair_name" {
  description = "Name of the keypair"
  type        = string
  default     = ""
}

variable "instance_secretsmanager_name" {
  description = "Name of the secret"
  type        = string
  default     = ""
}

variable "secret_manager_recovery_window_in_days" {
  description = "Recovery window in days"
  type        = number
  default     = 0
}

variable "database_secret_ssm_parameter" {
  description = "Name of the SSM parameter for the database secret"
  type        = string
  default     = ""
}

variable "instance_name_prefix" {
  description = "Prefix of the instance name"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number

  validation {
    condition     = var.instance_count >= 1
    error_message = "The number of instances should be 1 or more."
  }
}

variable "instance_config" {
  description = "Lightsail instance parameters"
  type = object({
    availability_zone = string
    blueprint_id      = string
    bundle_id         = string
    ip_address_type   = string
  })
}

variable "lightsail_database" {
  description = "Map of Lightsail databases to be created (optional)"
  type = map(object({
    relational_database_name = string
    availability_zone        = string
    master_database_name     = string
    master_username          = string
    blueprint_id             = string
    bundle_id                = string
    skip_final_snapshot      = bool
  }))
  default = {}
}

variable "lb_ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "IP address type of the load balancer"
}

variable "lb_health_check_path" {
  type        = string
  default     = "/"
  description = "Health check path for the load balancer"
}
