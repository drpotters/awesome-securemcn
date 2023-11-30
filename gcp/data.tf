terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-gcp"
    }
  }
}

data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
} 


data "google_compute_zones" "zones" {
  project = local.gcpProjectId
  region  = local.gcpRegion
  status  = "UP"
}