terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-azure"
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

data "azurerm_network_interface" "master-0" {
  name = "master-0-slo"
  resource_group_name = format("%s-%s-f5xc", local.projectPrefix, local.buildSuffix)

  depends_on = [ volterra_tf_params_action.apply ]
}

data "azurerm_subnet" "public" {
  name = "public"
  virtual_network_name = module.network.vnet_name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [ module.network ]
}