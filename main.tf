terraform {
  required_version = ">= 1.2"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.18"
    }
  }
}

provider "volterra" {
  url          = "https://tme-lab-works.console.ves.volterra.io/api"
}

# Used to generate a random build suffix
resource "random_id" "buildSuffix" {
  byte_length = 2
}

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
}

locals {
  # Allow user to specify a build suffix, but fallback to random as needed.
  buildSuffix = coalesce(var.buildSuffix, random_id.buildSuffix.hex)
  commonLabels = {
    demo   = "f5xc-mcn"
    owner  = var.resourceOwner
    prefix = var.projectPrefix
    suffix = local.buildSuffix
  }

  # Nice to have for local execution, but with remote execution this IP becomes the TerraForm Cloud Agent, not what we want
  #commonClientIP = format("%s/32", data.http.ipinfo.response_body)
}

# Create a virtual site that will identify services deployed in AWS, Azure, and GCP.
resource "volterra_virtual_site" "site" {
  name        = format("%s-vsite-%s", var.projectPrefix, local.buildSuffix)
  namespace   = "shared"
  description = format("Virtual site for %s-%s", var.projectPrefix, local.buildSuffix)
  labels      = local.commonLabels
  site_type   = "CUSTOMER_EDGE"
  site_selector {
    expressions = [
      join(",", [for k, v in local.commonLabels : format("%s = %s", k, v)])
    ]
  }
}

# Create global network to connect the sites using a site mesh group
resource "volterra_virtual_network" "global_vn" {
  name = format("%s-gn-%s", var.projectPrefix, local.buildSuffix)
  namespace = "system"
  global_network = true
  site_local_network = true
  site_local_inside_network = false
}

# Create full site mesh group with a label selector that each CE Site will be labeled on creation
resource "volterra_site_mesh_group" "smg" {
  name = format("%s-smg-%s", var.projectPrefix, local.buildSuffix)
  namespace = "system"

  virtual_site {
    name = volterra_virtual_site.site.name
    namespace = "shared"
    tenant = var.xc_tenant
  }
  full_mesh {
    control_and_data_plane_mesh = true
  }

  depends_on = [volterra_virtual_site.site]
}
