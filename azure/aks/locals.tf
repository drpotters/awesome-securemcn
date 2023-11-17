locals {
  resourceGroup = data.tfe_outputs.azure.values.resourceGroup
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  vnetName = data.tfe_outputs.azure.values.vnetName
}