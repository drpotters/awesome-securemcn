terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-aws-eks"
    }
  }
}
data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}
data "tfe_outputs" "aws" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws"
}

# Retrieve availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "workload_subnet" {
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*workload-${local.buildSuffix}"]
  }
}

data "aws_subnet" "inside_subnet" {
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*inside-${local.buildSuffix}"]
  }
}

data "aws_subnet" "slo_subnet" {
  for_each          = {for i, az_name in local.azs: i => az_name}
  availability_zone = local.azs[each.key]
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*vpc-${local.buildSuffix}"]
  }
}

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
}