terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-azure-workload"
    }
  }
}

data "tfe_outputs" "root" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-root"
}
data "tfe_outputs" "azure" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure"
}
data "tfe_outputs" "aks" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-azure-aks"
}
data "tfe_outputs" "aws-workload" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-aws-workload"
}

data "azurerm_resource_group" "rg" {
  name = data.tfe_outputs.azure.values.resourceGroup
}

data "kubernetes_service_v1" "api" {
  metadata {
    name = "app2"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  depends_on = [kubernetes_deployment.app2]
}

data "azurerm_network_interface" "master-0" {
  name = "master-0-slo"
  resource_group_name = format("%s-%s-f5xc", local.project_prefix, local.build_suffix)
}
