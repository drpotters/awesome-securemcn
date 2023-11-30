############################ Locals ############################
locals {
  projectPrefix = data.tfe_outputs.root.values.projectPrefix
  resourceOwner = data.tfe_outputs.root.values.resourceOwner
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  commonClientIP = data.tfe_outputs.root.values.commonClientIP
  azure_cidr = data.tfe_outputs.root.values.azure_cidr
  aws_cidr = data.tfe_outputs.root.values.aws_cidr
  azureLocation = data.tfe_outputs.root.values.azureLocation
  cluster_name = format("%s-%s-aks-cluster", local.projectPrefix, local.buildSuffix)
  f5xcCommonLabels = merge(var.labels, {
    demo     = "f5xc-mcn"
    owner    = local.resourceOwner
    prefix   = local.projectPrefix
    suffix   = local.buildSuffix
    platform = "azure"
  })
  f5xcResourceGroup = format("%s-%s-f5xc", local.projectPrefix, local.buildSuffix)
  xc_site_slo_ip = data.azurerm_network_interface.master-0.private_ip_address
  ssh_id = data.tfe_outputs.root.values.ssh_id
  xc_tenant = data.tfe_outputs.root.values.xc_tenant
  namespace = data.tfe_outputs.root.values.namespace
  f5xcCloudCredAzure = data.tfe_outputs.root.values.f5xcCloudCredAzure
}