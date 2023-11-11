output "vnetId" {
  description = "VNet ID"
  value       = module.network.vnet_id
}
output "vnetName" {
  description = "VNet Name"
  value       = nonsensitive(module.network.vnet_name)
}
output "resourceGroup" {
  description  = "Name of the Azure Resource Group"
  value        = nonsensitive(azurerm_resource_group.rg.name)
}
output "webserver_private_ip" {
  value       = azurerm_network_interface.webserver.private_ip_address
  description = "Private IP address of web server"
}
output "webserver_public_ip" {
  value       = azurerm_public_ip.webserver[0].ip_address
  description = "Public IP address of web server"
}
output "site_name" {
  description = "The name of the site in F5 XC"
  value = nonsensitive(volterra_azure_vnet_site.xc.name)
}
output "vnetCidr" {
  description = "CIDR block for the Azure VNet"
  value = var.vnetCidr
}