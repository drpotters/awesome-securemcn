locals {
  resourceGroup = data.tfe_outputs.azure.values.resourceGroup
  resourceOwner = data.tfe_outputs.root.values.resourceOwner
  projectPrefix = data.tfe_outputs.root.values.projectPrefix
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  vnetName = data.tfe_outputs.azure.values.vnetName
  xc_tenant = data.tfe_outputs.root.values.xc_tenant
  namespace = data.tfe_outputs.root.values.namespace
  f5xcCloudCredAzure = data.tfe_outputs.root.values.f5xcCloudCredAzure
  azureLocation = data.tfe_outputs.root.values.azureLocation
}