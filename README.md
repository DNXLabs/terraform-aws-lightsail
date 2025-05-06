
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
  source = "./modules/terraform-aws-lightsail"

  keypair_name                  = "keypair-non-prd-deploy-wordpress"
  instance_secretsmanager_name  = "keypair-lightsail-non-prd"
  recovery_window_in_days       = 0
  database_secret_ssm_parameter = "/non-prd/wordpress/database"
  use_external_db               = false

  lb_name                       = "lb-wordpress-non-prd"
  instance_port                 = 80

  default_ports = [
    {
      from_port = 22
      protocol  = "tcp"
      to_port   = 22
      cidrs     = ["184.147.56.64/32"] #your ip
    }
  ]

  lightsail_instances = {
    wp01 = {
      name              = "wordpress-non-prd-01"
      availability_zone = "ap-southeast-2a"
      blueprint_id      = "wordpress"
      bundle_id         = "nano_3_2"
      ip_address_type   = "ipv4"
    }
  }
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
  source = "./modules/terraform-aws-lightsail"

  keypair_name                  = "keypair-non-prd-deploy-wordpress"
  instance_secretsmanager_name  = "keypair-lightsail-non-prd"
  recovery_window_in_days       = 0
  database_secret_ssm_parameter = "/non-prd/wordpress/database"
  use_external_db               = true

  lb_name                       = "lb-wordpress-non-prd"
  instance_port                 = 80
  domain_name                   = "non-prd.mydomain.com"
  attach_certificate_to_lb      = false #only should be true after domain validation

  default_ports = [
    {
      from_port = 22
      protocol  = "tcp"
      to_port   = 22
      cidrs     = ["184.147.56.64/32"] #your ip
    }
  ]

  lightsail_instances = {
    wp01 = {
      name              = "wordpress-non-prd-01"
      availability_zone = "ap-southeast-2a"
      blueprint_id      = "wordpress"
      bundle_id         = "nano_3_2"
      ip_address_type   = "ipv4"
    },
    wp02 = {
      name              = "wordpress-non-prd-02"
      availability_zone = "ap-southeast-2a"
      blueprint_id      = "wordpress"
      bundle_id         = "nano_3_2"
      ip_address_type   = "ipv4"
    }
  }

  lightsail_database = {
    db01 = {
      relational_database_name = "wordpress-db-non-prd"
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
