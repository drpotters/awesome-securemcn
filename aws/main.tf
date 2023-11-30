########################### Providers ##########################

terraform {
  required_version = "~> 1.0"

  required_providers {
    volterra = {
      source    = "volterraedge/volterra"
      version  = ">= 0.11.26"
    }
    aws = "~> 4.0"
  }
}

provider "aws" {
  region = local.awsRegion
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}

provider "volterra" {
  timeout = "90s"
}





############################ VPCs ############################

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.19.0"
  name                 = format("%s-vpc-%s", local.projectPrefix, local.buildSuffix)
  cidr                 = local.aws_cidr[0].vpcCidr
  azs                  = [local.awsAz1, local.awsAz2]
  public_subnets       = nonsensitive(local.aws_cidr[0].publicSubnets)
  enable_dns_hostnames = true
  tags = merge(local.f5xcCommonLabels, {
    Name  = format("%s-vpc-%s", local.projectPrefix, local.buildSuffix)
    Owner = local.resourceOwner
  })
}

############################ Web Server Subnets ############################

# @JeffGiroux workaround VPC module
# - Need private subnet to reach internet to download onboarding files.
# - Will associate public route table with private subnet for demo purposes.
# - Note: Best practice is to use NAT gateway and bastion host.
resource "aws_subnet" "private" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = nonsensitive(local.aws_cidr[0].privateSubnets[0])

  tags = {
    Name  = format("%s-private-%s", local.projectPrefix, local.buildSuffix)
    Owner = local.resourceOwner
  }
}

resource "aws_route_table_association" "private_routes" {
  subnet_id      = aws_subnet.private.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

# @DavePotter add route table entries for each of the cloud deployment CIDR blocks
resource "aws_route" "route_to_azure_via_xc" {
  route_table_id = module.vpc.public_route_table_ids[0]
  destination_cidr_block = local.azure_cidr[0].vnet[0].vnetCidr
  network_interface_id = data.aws_network_interface.xc_slo.id
}
resource "aws_route" "route_to_google_via_xc" {
  route_table_id = module.vpc.public_route_table_ids[0]
  destination_cidr_block = local.gcp_cidr[0].slo
  network_interface_id = data.aws_network_interface.xc_slo.id
}
############################ F5 XC Subnets ############################

# @JeffGiroux workaround route table association conflict
# - AWS VPC module creates subnets with RT associations, and
# - F5 XC tries to create which causes conflicts and fails.
# - Create additional subnets for SLI and Workload without route tables.

resource "aws_subnet" "sli" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = nonsensitive(local.aws_cidr[0].sliSubnets[0])

  tags = {
    Name  = format("%s-site-local-inside-%s", local.projectPrefix, local.buildSuffix)
    Owner = local.resourceOwner
  }
}

resource "aws_subnet" "workload" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = nonsensitive(local.aws_cidr[0].workloadSubnets[0])

  tags = {
    Name  = format("%s-workload-%s", local.projectPrefix, local.buildSuffix)
    Owner = local.resourceOwner
  }
}

############################ SSH Key ############################

# SSH key
resource "aws_key_pair" "sshKey" {
  key_name   = format("%s-sshKey-%s", local.projectPrefix, local.buildSuffix)
  public_key = var.ssh_id
}

############################ Security Groups - Web Servers ############################

# Webserver Security Group
resource "aws_security_group" "webserver" {
  name        = format("%s-sg-webservers-%s", local.projectPrefix, local.buildSuffix)
  description = "Webservers security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.tfe_outputs.root.values.commonClientIP]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.tfe_outputs.root.values.commonClientIP]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.aws_cidr[0].vpcCidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-webservers-%s", local.projectPrefix, local.buildSuffix)
    Owner = local.resourceOwner
  }
}
