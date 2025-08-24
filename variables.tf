# JLAM Infrastructure Variables
# Terraform Cloud Workspace: jlam-infrastructure

# REMOVED - Using environment variables SCW_* instead
# variable "scaleway_access_key" { ... }
# variable "scaleway_secret_key" { ... } 
# variable "scaleway_organization_id" { ... }

variable "scaleway_project_id" {
  description = "Scaleway Project ID"
  type        = string
  default     = "c57d808d-1af5-4117-9edc-a4f5680611e6"
  sensitive   = true
}

# REMOVED - Using file() function to read SSH key directly
# variable "ssh_public_key" { ... }

variable "zone" {
  description = "Scaleway zone"
  type        = string
  default     = "nl-ams-1"
}

variable "region" {
  description = "Scaleway region"
  type        = string
  default     = "nl-ams"
}

variable "instance_type" {
  description = "Server instance type"
  type        = string
  default     = "DEV1-M" # 2 vCPU, 3GB RAM, 40GB SSD
}

variable "deployment_timestamp" {
  description = "Deployment timestamp for forensic tracking"
  type        = string
  default     = ""
}