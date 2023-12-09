output "buildSuffix" {
  description = "build suffix for the deployment"
  value       = local.buildSuffix
}
output "projectPrefix" {
  value = var.projectPrefix
}
output "f5xcVirtualSite" {
  description = "name of virtual site across all clouds"
  value       = volterra_virtual_site.site.name
}
output "commonClientIP" {
  description = "IP Address of the client to use in network security groups"
  value       = var.commonClientIP
  sensitive   = true
}
output "ssh_id" {
  value     = var.ssh_id
  sensitive = true
}
output "xc_global_vn" {
  description = "Name of the F5XC Global Network"
  value       = volterra_virtual_network.global_vn.name
}
output "aws_cidr" {
  value = var.aws_cidr
}
output "awsRegion" {
  value = var.awsRegion
}
output "azure_cidr" {
  value = var.azure_cidr
}
output "azureLocation" {
  value = var.azureLocation
}
output "gcp_cidr" {
  value = var.gcp_cidr
}
output "gcpProjectId" {
  value = var.gcpProjectId
  sensitive = true
}
output "gcpRegion" {
  value = var.gcpRegion
}
output "namespace" {
  value = var.namespace
}
output "resourceOwner" {
  value = var.resourceOwner
}
output "xc_tenant" {
  value = var.xc_tenant
  sensitive = true
}
output "f5xcCloudCredAzure" {
  value = var.f5xcCloudCredAzure
  sensitive = true
}
output "f5xcCloudCredAWS" {
  value = var.f5xcCloudCredAWS
  sensitive = true
}
output "f5xcCloudCredGCP" {
  value = var.f5xcCloudCredGCP
  sensitive = true
}
output "app_domain" {
  value = var.app_domain
}