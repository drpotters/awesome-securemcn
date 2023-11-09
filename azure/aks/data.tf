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