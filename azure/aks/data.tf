terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-azure-aks"
    }
  }
}

data "tfe_outputs" "azure" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure"
}

data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}

# Retrieve various resources in Azure
data "azurerm_subscription" "primary" {
}
data "azurerm_client_config" "current" {
}
data "azurerm_resource_group" "rg" {
  name = local.resourceGroup
}
data "azurerm_subnet" "nodes" {
  name                 = "public"
  virtual_network_name = local.vnetName
  resource_group_name  = local.resourceGroup
}
data "azurerm_subnet" "pods" {
  name                 = "workload"
  virtual_network_name = local.vnetName
  resource_group_name  = local.resourceGroup
}