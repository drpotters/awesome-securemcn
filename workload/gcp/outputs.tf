# Display load balancer hostname (typically present in AWS)
/* output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.app3-ingress.status.0.load_balancer.0.ingress.0.hostname
} */

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress_v1.app3-ingress.status[0].load_balancer[0].ingress[0].ip
}