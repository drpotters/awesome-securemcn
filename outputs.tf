output "buildSuffix" {
  description = "build suffix for the deployment"
  value       = local.buildSuffix
}
output "f5xcVirtualSite" {
  description = "name of virtual site across all clouds"
  value       = volterra_virtual_site.site.name
}
output "commonClientIP" {
  description = "IP Address of the client to use in network security groups"
  value       = var.commonClientIP
}
output "xc_global_vn" {
  description = "Name of the F5XC Global Network"
  value = volterra_virtual_network.global_vn.name
}