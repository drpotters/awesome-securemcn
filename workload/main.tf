terraform {
  required_version = ">= 0.14.0"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.18"
    }
    aws = ">= 4"
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.76.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.16.1"
    }
  }
}
provider "volterra" {
  api_p12_file = "./api.p12"
  url          = "https://tme-lab-works.console.ves.volterra.io/api"
}
provider "azurerm" {
  features {}
}
provider "aws" {
    region     = local.aws_region
}

provider "kubernetes" {
  alias = "aks"
  host = local.aks_host
  client_certificate = local.aks_client_certificate
  client_key = local.aks_client_key
  cluster_ca_certificate = local.aks_cluster_ca_certificate
}
provider "kubernetes" {
  alias = "eks"
  host = local.eks_host
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
  token = data.aws_eks_cluster_auth.auth.token
}