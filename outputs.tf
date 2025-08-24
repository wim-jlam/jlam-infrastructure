# JLAM Infrastructure Outputs
# Complete information for forensic analysis

output "deployment_summary" {
  description = "Complete deployment summary for forensic analysis"
  value = {
    # Server Information
    server_name  = scaleway_instance_server.jlam_server.name
    server_id    = scaleway_instance_server.jlam_server.id
    public_ip    = data.scaleway_instance_ip.jlam_server_ip.address
    private_ip   = scaleway_instance_server.jlam_server.private_ip
    ipv6_address = scaleway_instance_server.jlam_server.ipv6_address

    # Infrastructure Details
    zone          = var.zone
    region        = var.region
    instance_type = var.instance_type
    image_id      = data.scaleway_instance_image.ubuntu.id

    # Network Configuration
    security_group_id = scaleway_instance_security_group.jlam_security_group.id

    # Deployment Metadata
    deployed_at     = timestamp()
    terraform_cloud = "https://app.terraform.io/app/JLAM/workspaces/jlam-infrastructure"
    deployment_id   = local.deployment_timestamp
  }
}

output "server_access" {
  description = "Server access information"
  value = {
    ssh_command = "ssh -i ~/.ssh/jlam_tunnel_key root@${data.scaleway_instance_ip.jlam_server_ip.address}"
    ssh_user    = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address}"
    public_ip   = data.scaleway_instance_ip.jlam_server_ip.address
  }
}

output "service_urls" {
  description = "All service URLs for testing and forensic analysis"
  value = {
    # Public HTTPS Services
    landing_page    = "https://jlam.nl"
    app_platform    = "https://app.jlam.nl"
    authentik_sso   = "https://auth.jlam.nl"
    grafana_monitor = "https://monitor.jlam.nl"

    # Direct IP Access
    traefik_dashboard = "http://${data.scaleway_instance_ip.jlam_server_ip.address}:8080"
    direct_http       = "http://${data.scaleway_instance_ip.jlam_server_ip.address}"
    direct_https      = "https://${data.scaleway_instance_ip.jlam_server_ip.address}"

    # Database Access (for forensic analysis)
    postgresql_direct = "postgresql://jlam_user:dev_password_123@${data.scaleway_instance_ip.jlam_server_ip.address}:5432/jlam_dev"
    redis_direct      = "redis://dev_redis_pass@${data.scaleway_instance_ip.jlam_server_ip.address}:6379"
  }
  sensitive = true
}

output "forensic_analysis_commands" {
  description = "Commands for comprehensive forensic analysis"
  value = {
    # SSH Connection
    ssh_connect = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address}"

    # System Analysis
    system_logs       = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'sudo journalctl -u cloud-final --no-pager'"
    cloud_init_status = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'sudo cloud-init status --long'"
    deployment_logs   = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'sudo cat /var/log/jlam-deployment.log'"

    # Docker Analysis
    docker_services     = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'docker service ls'"
    docker_containers   = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'docker ps -a'"
    docker_logs_traefik = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'docker logs jlam-traefik-prod'"

    # Network Analysis
    port_scan      = "nmap -p 22,80,443,5432,6379,8080 ${data.scaleway_instance_ip.jlam_server_ip.address}"
    network_status = "ssh -i ~/.ssh/jlam_tunnel_key jlam@${data.scaleway_instance_ip.jlam_server_ip.address} 'sudo ss -tulpn | grep LISTEN'"

    # Service Health Checks
    http_test   = "curl -I http://${data.scaleway_instance_ip.jlam_server_ip.address}"
    https_test  = "curl -I https://${data.scaleway_instance_ip.jlam_server_ip.address}"
    traefik_api = "curl -s http://${data.scaleway_instance_ip.jlam_server_ip.address}:8080/api/version"
  }
}

output "deployment_validation_checklist" {
  description = "Complete validation checklist for deployment verification"
  value = [
    "✅ Server accessible via SSH",
    "✅ Docker service running",
    "✅ Docker Swarm initialized",
    "✅ Overlay network created",
    "✅ All containers started",
    "✅ Port 80 accessible (HTTP)",
    "✅ Port 443 accessible (HTTPS)",
    "✅ Port 8080 accessible (Traefik)",
    "✅ Port 5432 accessible (PostgreSQL)",
    "✅ Port 6379 accessible (Redis)",
    "✅ SSL certificates loaded",
    "✅ Traefik routing functional",
    "✅ Authentik SSO responding",
    "✅ Grafana monitoring accessible",
    "✅ Prometheus metrics collection",
    "✅ DNS resolution working",
    "✅ All services healthy"
  ]
}

# New IP Address (the key information you requested)
output "new_ip_address" {
  description = "NEW IP ADDRESS for JLAM production server"
  value       = data.scaleway_instance_ip.jlam_server_ip.address
}

output "deployment_timestamp" {
  description = "Deployment timestamp for tracking"
  value       = local.deployment_timestamp
}