terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-aws"
    }
  }
  required_version = ">= 0.14.0"
  required_providers {
    aws = ">= 4"
  }
}

data "tfe_outputs" "aws" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-aws"
}
data "tfe_outputs" "root" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-root"
}

import {
  to = aws_network_interface.xc_slo_nic
  id = data.tfe_outputs.aws.values.site_slo_eni
}

resource "aws_network_interface" "xc_slo_nic" {
  source_dest_check = false
}