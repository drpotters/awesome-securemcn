terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-azure"
    }
  }
}

data "tfe_outputs" "azure" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-azure"
}

data "tfe_outputs" "root" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-root"
}

data "azurerm_network_interface" "master-0" {
  name = "master-0-slo"
  resource_group_name = format("%s-%s-f5xc", local.project_prefix, local.build_suffix)

  depends_on = [ volterra_tf_params_action.apply ]
}