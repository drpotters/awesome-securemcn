terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-workload"
    }
  }
}

# Shared workspaces
data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}
data "tfe_outputs" "aws" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws"
}
data "tfe_outputs" "azure" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure"
}
data "tfe_outputs" "gcp" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp"
}
data "tfe_outputs" "eks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws-eks"
}
data "tfe_outputs" "aks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure-aks"
}
data "tfe_outputs" "gke" {
    organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-gcp-gke"
}
data "tfe_outputs" "nic" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-nic"
}
data "tfe_outputs" "app-workload" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-workload"
}

# AWS section
data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}
data "kubernetes_endpoints_v1" "origin-pool-k8s-service" {
  provider = kubernetes.eks

  metadata {
    name = local.aws_service_name
    namespace = "nginx-ingress"
  }
}


# Azure section
data "azurerm_resource_group" "rg" {
  name = data.tfe_outputs.azure.values.resourceGroup
}
data "kubernetes_service_v1" "api" {
  provider = kubernetes.aks

  metadata {
    name = "app2"
    namespace = kubernetes_namespace.aks-app.metadata[0].name
  }
  depends_on = [kubernetes_deployment.app2]
}
data "azurerm_network_interface" "master-0" {
  name = "master-0-slo"
  resource_group_name = format("%s-%s-f5xc", local.projectPrefix, local.buildSuffix)
}

# GCP
data "google_client_config" "default" {}
data "google_service_account" "me" {
  account_id = "f5dc-gcp-vpc-svc-acct@f5-gcs-5611-mktg-secsols.iam.gserviceaccount.com"
}
data "google_compute_network" "lb-net" {
  name = data.tfe_outputs.gcp.values.network_name_outside
  project = local.gcpProjectId
}
data "google_compute_subnetwork" "lb-proxy-subnet" {
  name = "${local.projectPrefix}-${local.buildSuffix}-proxy-only"
  project = local.gcpProjectId
}