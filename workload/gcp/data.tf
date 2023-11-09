terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-gcp-workload"
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
data "tfe_outputs" "eks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws-eks"
}

data "tfe_outputs" "gcp" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp"
}
data "tfe_outputs" "gke" {
    organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp-gke"
}

data "google_client_config" "default" {}

data "google_service_account" "me" {
  account_id = "f5dc-gcp-vpc-svc-acct@f5-gcs-5611-mktg-secsols.iam.gserviceaccount.com"
}
data "google_compute_network" "lb-net" {
  name = data.tfe_outputs.gcp.values.network_name_outside
  project = var.gcpProjectId
}

data "google_compute_subnetwork" "lb-proxy-subnet" {
  name = "${local.project_prefix}-${local.buildSuffix}-proxy-only"
  project = var.gcpProjectId
}