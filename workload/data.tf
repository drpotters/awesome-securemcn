terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-xc"
    }
  }
}

# Common
data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}

# AWS
data "tfe_outputs" "aws" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws"
}
data "tfe_outputs" "eks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws-eks"
}
data "tfe_outputs" "nic" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-nic"
}
data "tfe_outputs" "aws-workload" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws-workload"
}
data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}

# Azure
data "tfe_outputs" "azure" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure"
}
data "tfe_outputs" "aks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure-aks"
}
data "tfe_outputs" "azure-workload" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure-workload"
}

# Google
data "tfe_outputs" "google" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp"
}
data "tfe_outputs" "google-workload" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp-workload"
}