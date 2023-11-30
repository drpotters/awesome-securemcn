terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-aws"
    }
  }
}

data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}

############################ Collect XC Node Info ############################

# Instance info
data "aws_instances" "xc" {
  instance_state_names = ["running"]
  instance_tags = {
    "ves-io-site-name" = volterra_aws_vpc_site.xc.name
  }

  depends_on = [volterra_tf_params_action.apply]
}

# Retrieve availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# NIC info
data "aws_network_interface" "xc_sli" {
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.xc.ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-inside"]
  }
}

# NIC info
data "aws_network_interface" "xc_slo" {
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instances.xc.ids[0]]
  }
  filter {
    name   = "tag:ves.io/interface-type"
    values = ["site-local-outside"]
  }
}