provider "google" {
  region  = var.gcpRegion
  project = var.gcpRegion
}

provider "kubernetes" {
    host = local.gke_host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token = local.token
}