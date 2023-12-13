locals {
  project_id      = nonsensitive(data.tfe_outputs.root.values.gcpProjectId)
  region          = data.tfe_outputs.root.values.gcpRegion
  network_name    = data.tfe_outputs.gcp-infra.values.network_name_outside
  subnet_name     = data.tfe_outputs.gcp-infra.values.subnet_name_outside
  gcp_cidr        = data.tfe_outputs.root.values.gcp_cidr
  projectPrefix   = data.tfe_outputs.root.values.projectPrefix
  buildSuffix     = data.tfe_outputs.root.values.buildSuffix
  deployment_name = format("%s-%s-gke-cluster", local.projectPrefix, local.buildSuffix)
}
