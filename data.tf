terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-root"
    }
  }
}

#data "terraform_remote_state" "globals" {
#  backend = "local"
#}

#data "tfe_outputs" "root" {
#  organization = "example-org-fa8f78"
#  workspace = "xcmcn-ce"
#}

#resource "tfe_workspace" "xcmcn-ce" {
#  name = "xcmcn-ce"
#}

