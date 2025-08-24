# JLAM Infrastructure - Production Server Deployment
# Terraform Cloud Workspace: jlam-infrastructure
# Clean deployment with comprehensive forensic analysis

# Local values for forensic tracking
locals {
  deployment_timestamp = var.deployment_timestamp != "" ? var.deployment_timestamp : formatdate("YYYY-MM-DD-hhmm", timestamp())
  server_name          = "jlam-production-${local.deployment_timestamp}"

  # SSL certificates (base64 encoded from local config)
  ssl_files = {
    certificate = fileexists("config/ssl/certificate.crt") ? filebase64("config/ssl/certificate.crt") : ""
    key         = fileexists("config/ssl/certificate.key") ? filebase64("config/ssl/certificate.key") : ""
    cabundle    = fileexists("config/ssl/cabundle.crt") ? filebase64("config/ssl/cabundle.crt") : ""
  }

  # Cloud-init template with SSL certificates - WORKING PRODUCTION VERSION (Reverse Engineered)
  cloud_init = templatefile("${path.module}/cloud-init-production-working.yml", {
    ssh_public_key      = file("~/.ssh/jlam_tunnel_key.pub")
    ssl_certificate_crt = local.ssl_files.certificate
    ssl_certificate_key = local.ssl_files.key
    ssl_cabundle_crt    = local.ssl_files.cabundle
  })
}

# Use existing IP Address (manually kept)
data "scaleway_instance_ip" "jlam_server_ip" {
  address = "51.158.190.109"
}

# Security Group with comprehensive access
resource "scaleway_instance_security_group" "jlam_security_group" {
  name        = "jlam-production-sg-${local.deployment_timestamp}"
  description = "JLAM production server security group with forensic access"

  # SSH Access for forensic analysis
  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # HTTP (will redirect to HTTPS)
  inbound_rule {
    action   = "accept"
    port     = "80"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # HTTPS (main services)
  inbound_rule {
    action   = "accept"
    port     = "443"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # Traefik Dashboard for monitoring
  inbound_rule {
    action   = "accept"
    port     = "8080"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # Database access for forensic analysis
  inbound_rule {
    action   = "accept"
    port     = "5432"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # Redis access for forensic analysis  
  inbound_rule {
    action   = "accept"
    port     = "6379"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  # Allow all outbound
  outbound_rule {
    action   = "accept"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  tags = [
    "environment:production",
    "project:jlam",
    "forensic:enabled"
  ]
}

# JLAM Production Server
resource "scaleway_instance_server" "jlam_server" {
  name              = local.server_name
  image             = data.scaleway_instance_image.ubuntu.id
  type              = var.instance_type
  zone              = var.zone
  security_group_id = scaleway_instance_security_group.jlam_security_group.id
  ip_id             = data.scaleway_instance_ip.jlam_server_ip.id

  # Cloud-init configuration with forensic logging
  user_data = {
    cloud-init = local.cloud_init
  }

  # IPv6 disabled due to routed IP conflict

  # Boot configuration
  boot_type = "local"

  # Root volume configuration
  root_volume {
    size_in_gb            = 40
    delete_on_termination = true
  }

  tags = [
    "environment:production",
    "project:jlam",
    "deployment:terraform-cloud",
    "forensic:enabled",
    "timestamp:${local.deployment_timestamp}",
    "ssl:configured",
    "monitoring:enabled"
  ]
}

# Local file for forensic analysis tracking
resource "local_file" "deployment_info" {
  filename = "${path.module}/deployment-${local.deployment_timestamp}.json"
  content = jsonencode({
    deployment_id   = local.deployment_timestamp
    server_name     = local.server_name
    server_id       = scaleway_instance_server.jlam_server.id
    public_ip       = data.scaleway_instance_ip.jlam_server_ip.address
    private_ip      = scaleway_instance_server.jlam_server.private_ip
    zone            = var.zone
    instance_type   = var.instance_type
    deployed_at     = timestamp()
    terraform_cloud = "https://app.terraform.io/app/JLAM/workspaces/jlam-infrastructure"
    ssl_configured  = local.ssl_files.certificate != "" ? true : false
    forensic_logs = [
      "/var/log/cloud-init.log",
      "/var/log/cloud-init-output.log",
      "/var/log/cloud-init-forensic.log",
      "/var/log/jlam-deployment.log",
      "/var/log/jlam/"
    ]
    services = [
      "traefik:443,80,8080",
      "postgres:5432",
      "redis:6379",
      "authentik:9000",
      "grafana:3000",
      "prometheus:9090"
    ]
  })
}