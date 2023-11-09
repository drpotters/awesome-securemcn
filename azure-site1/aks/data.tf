terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-azure-aks"
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