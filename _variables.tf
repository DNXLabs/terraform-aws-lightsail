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

variable "default_ports" {
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

variable "recovery_window_in_days" {
  description = "Recovery window in days"
  type        = number
  default     = 0
}

variable "database_secret_ssm_parameter" {
  description = "Name of the SSM parameter for the database secret"
  type        = string
  default     = ""
}

variable "lightsail_instances" {
  description = "Mapa de instâncias Lightsail a serem criadas"
  type = map(object({
    name              = string
    availability_zone = string
    blueprint_id      = string
    bundle_id         = string
    ip_address_type   = string
  }))
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

  validation {
    condition     = var.use_external_db == false || length(var.lightsail_database) > 0
    error_message = "You must provide at least one lightsail_database entry when use_external_db is true."
  }
}