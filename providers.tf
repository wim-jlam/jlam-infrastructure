# JLAM Infrastructure Providers
# Terraform Cloud Integration with Forensic Analysis Capabilities

terraform {
  required_version = ">= 1.0"

  # TEMPORARILY DISABLED - Using local deployment for immediate cloud-init fix
  # cloud {
  #   organization = "JLAM"
  #   workspaces {
  #     name = "jlam-infrastructure"
  #   }
  # }

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.34"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Scaleway Provider Configuration - Uses environment variables
provider "scaleway" {
  # Uses SCW_ACCESS_KEY, SCW_SECRET_KEY, SCW_DEFAULT_ORGANIZATION_ID from environment
  # project_id      = var.scaleway_project_id
  zone   = var.zone
  region = var.region
}

# Data sources for forensic analysis
data "scaleway_availability_zones" "available" {}
data "scaleway_instance_image" "ubuntu" {
  architecture = "x86_64"
  name         = "Ubuntu 22.04 Jammy Jellyfish"
}