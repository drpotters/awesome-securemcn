provider "volterra" {
  api_p12_file = "./api.p12"
  url          = "https://tme-lab-works.console.ves.volterra.io/api"
}
provider "kubernetes" {
      host = local.host
      client_certificate = local.client_certificate
      client_key = local.client_key
      cluster_ca_certificate = local.cluster_ca_certificate
}
provider "helm" {
      host = local.host
      client_certificate = local.client_certificate
      client_key = local.client_key
      cluster_ca_certificate = local.cluster_ca_certificate
      
}
provider "azurerm" {
  features {}
}