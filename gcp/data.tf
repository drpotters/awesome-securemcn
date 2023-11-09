terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-gcp"
    }
  }
}

data "tfe_outputs" "root" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-root"
}