locals {
  project_id = var.gcpProjectId
  region = var.gcpRegion
  network_name    = data.tfe_outputs.gcp-infra.values.network_name_outside
  subnet_name = data.tfe_outputs.gcp-infra.values.subnet_name_outside
  deployment_name = format("%s-%s-gke-cluster", var.projectPrefix, data.tfe_outputs.root.values.buildSuffix)
}
