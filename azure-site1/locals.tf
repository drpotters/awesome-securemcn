############################ Locals ############################
locals {
  project_prefix = var.projectPrefix
  resource_owner = var.resourceOwner
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  commonClientIP = data.tfe_outputs.root.values.commonClientIP
  azure_region = var.azureLocation
  cluster_name = format("%s-%s-aks-cluster", var.projectPrefix, local.build_suffix)
  f5xcCommonLabels = merge(var.labels, {
    demo     = "f5xc-mcn"
    owner    = var.resourceOwner
    prefix   = var.projectPrefix
    suffix   = local.build_suffix
    platform = "azure"
  })
  f5xcResourceGroup = format("%s-%s-f5xc", var.projectPrefix, local.build_suffix)
  xc_site_slo_ip = data.azurerm_network_interface.master-0.private_ip_address
}