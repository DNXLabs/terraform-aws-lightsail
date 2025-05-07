
# Terraform Module - WordPress on AWS Lightsail

This module provisions a basic infrastructure for running WordPress on AWS Lightsail. It supports two configuration modes:

- Using the **internal database** included in the Bitnami WordPress image (ideal for testing or simple environments).
- Provisioning an **external Lightsail Database (MySQL)** for greater control and scalability.

---

## Configuration Options

### Without External Database

- Creates **1 WordPress instance**
- Exposes only **port 80**
- Uses the **internal database** from the Bitnami image
- **Does not create** external DB, Parameter Store or user_data

```hcl
module "lightsail_wordpress" {
  source = "./modules/git/terraform-aws-lightsail"

  instance_name_prefix = "wordpress-non-prd"
  instance_count       = 1
  instance_config      = {
    availability_zone  = "ap-southeast-2a"
    blueprint_id       = "wordpress"
    bundle_id          = "nano_3_2"
    ip_address_type    = "ipv4"
  }

  default_ports_open_lightsail_instances = [
    {
      from_port = 22
      protocol  = "tcp"
      to_port   = 22
      cidrs     = ["184.147.56.64/32"] #your ip
    }
  ]

  secret_manager_recovery_window_in_days   = 0

  lb_name                       = "lb-wordpress-non-prd"
  instance_port                 = 80
  use_external_db               = false
}

```

### With External Database and Multiples Instances (MySQL on Lightsail)

Creates **2 WordPress instances**

Exposes ports **80** and **443**

Provisions a **Lightsail MySQL database**

Generates and stores **DB password in SSM Parameter Store**

Generates and stores **SSH key in Secrets Manager**

Uses user_data to configure DB and enable **phpMyAdmin** do the external db

```hcl
module "lightsail_wordpress" {
  source = "./modules/git/terraform-aws-lightsail"

  instance_name_prefix = "wordpress-prd"
  instance_count       = 2
  instance_config      = {
    availability_zone  = "ap-southeast-2a"
    blueprint_id       = "wordpress"
    bundle_id          = "nano_3_2"
    ip_address_type    = "ipv4"
  }

  default_ports_open_lightsail_instances = [
    {
      from_port = 22
      protocol  = "tcp"
      to_port   = 22
      cidrs     = ["184.147.56.64/32"] #your public or private ip to access instance ssh
    }
  ]

  secret_manager_recovery_window_in_days   = 0

  lb_name                       = "wordpress-prd"
  instance_port                 = 80
  domain_name                   = "prd.mydomain.com"
  hosted_zone_id                = "Z08817432UPMI00000000" #change to your zone
  create_dns_record             = true  #create a cname inside the route53 to lightsail lb
  create_certificate_record     = true  #create a certificate record inside the route53 to validate domain
  attach_certificate_to_lb      = false #only should be true after domain validation

  use_external_db               = true
  lightsail_database = {
    db01 = {
      relational_database_name = "wordpress-db-prd"
      availability_zone        = "ap-southeast-2a"
      master_database_name     = "master"
      master_username          = "admin"
      blueprint_id             = "mysql_8_0"
      bundle_id                = "micro_2_0"
      skip_final_snapshot      = true
    }
  }
}
```

## SSL Certificate (HTTPS)

If the domain_name variable is passed, a certificate will be created.

⚠️ Important: Set **attach_certificate_to_lb = true** only after the certificate is validated via DNS, or Terraform will fail to apply.

## user_data Template
The **user_data.sh.tpl** script is only used when **use_external_db = true**. It is responsible for:

* Configuring WordPress to connect to the external database
* Enabling **phpMyAdmin** for database management

## Passwords & Secrets
* The database password is **securely and randomly generated** using random_password.
* It is stored in **SSM Parameter Store.**
* The **SSH key** for Lightsail instances is stored in **AWS Secrets Manager**.


## Useful AWS CLI Commands
Use these commands to discover valid blueprint_id and bundle_id options:

```bash
# MySQL blueprints
aws lightsail get-relational-database-blueprints --region ap-southeast-2 --query "blueprints[?contains(name, 'mysql')]"

# MySQL bundles
aws lightsail get-relational-database-bundles --region ap-southeast-2

# Instance bundles
aws lightsail get-bundles --region ap-southeast-2

# WordPress blueprints
aws lightsail get-blueprints --region ap-southeast-2 --query "blueprints[?contains(name, 'WordPress')]"
```

These help you choose the right plan for performance and pricing.

## SSH Tunnel Access (for phpMyAdmin)
When using an external DB, phpMyAdmin is enabled on port 80. Access it securely using an SSH tunnel:

```bash
# SSH tunnel to access phpMyAdmin locally
ssh -i myssh.pem -N -L 8888:127.0.0.1:80 bitnami@<InstancePublicIP>

# Then open in your browser:
http://localhost:8888/phpmyadmin
```
Log in using the same **DB username** and **password** defined for your external database.
