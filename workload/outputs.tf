/* output "coredns-custom" {
    value = data.kubernetes_config_map_v1.coredns-custom
}

output "azure_service_endpoint_ip" {
    value = kubernetes_service.app2.status[0].load_balancer[0].ingress[0].ip
}

output "azure_ingress_service_port" {
    value = kubernetes_service.app2.spec[0].port[0].port
}
/* output "app2_endpoint_ip" {
    description = "Arcadia main will look for it"
    value       = data.kubernetes_service_v1.api.status[0].load_balancer[0].ingress[0].ip
} */

output "app_url" {
    description = "App URL"
    value       = "https://${volterra_http_loadbalancer.lb_https.domains[0]}"
}