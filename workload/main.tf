provider "volterra" {
  url          = "https://tme-lab-works.console.ves.volterra.io/api"
}
provider "kubernetes" {
  alias = "eks"
  host = local.eks_host
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
  token = data.aws_eks_cluster_auth.auth.token
}
provider "kubernetes" {
  alias = "aks"
  host = local.aks_host
  client_certificate = local.aks_client_certificate
  client_key = local.aks_client_key
  cluster_ca_certificate = local.aks_cluster_ca_certificate
}
provider "kubernetes" {
  alias = "gke"
  host = local.gke_host
  cluster_ca_certificate = base64decode(local.gke_cluster_ca_certificate)
  token = local.gke_token
}
provider "helm" {
  kubernetes {
    host = local.eks_host
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token = data.aws_eks_cluster_auth.auth.token  
  }
}

provider "aws" {
    region     = local.aws_region
}
provider "azurerm" {
  features {}
}
provider "google" {
  region  = var.gcpRegion
  project = var.gcpProjectId
}