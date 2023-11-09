locals {
  project_prefix = var.projectPrefix
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  gke_host = "https://${data.tfe_outputs.gke.values.kubernetes_cluster_host}"
  cluster_ca_certificate = data.tfe_outputs.gke.values.kubernetes_cluster_ca_certificate
  cluster_name = data.tfe_outputs.gke.values.kubernetes_cluster_name
  token = data.google_client_config.default.access_token
}

/*
output "kubernetes_cluster_name" {
  value       = nonsensitive(google_container_cluster.primary.name)
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_client_certificate" {
  value       = google_container_cluster.primary.master_auth.0.client_certificate
  description = "GKE Cluster Client Certificate"
}

output "kubernetes_cluster_client_key" {
  value       = nonsensitive(google_container_cluster.primary.master_auth.0.client_key)
  description = "GKE Cluster Client Key"
}

output "kubernetes_cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  description = "GKE Cluster CA Certificate"
}

output "kubernetes_cluster_access_token" {
  value       = nonsensitive(data.google_client_config.provider.access_token)
  description = "GKE Cluster Access Token"
}
*/