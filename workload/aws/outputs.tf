# Display load balancer hostname (typically present in AWS)
output "aws_ingress_load_balancer_hostname" {
  value = nonsensitive(data.tfe_outputs.nic.values.external_name)
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = nonsensitive(data.tfe_outputs.nic.values.external_ip)
}

# Display load balancer ingress port
output "load_balancer_port" {
  value = nonsensitive(data.tfe_outputs.nic.values.external_port)
}

output "app_fqdn" {
    value = var.app_domain
}

output "xcop_dynamic_service_name" {
    value = nonsensitive(format("%s-nic-%s-nginx-ingress-controller.nginx-ingress", var.projectPrefix, local.build_suffix))
}

output "service_endpoint_ip" {
    description = "App main and backend (files) ingress"
    value = local.service_endpoint_ip
}