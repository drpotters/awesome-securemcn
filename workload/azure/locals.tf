locals {
  project_prefix = var.projectPrefix
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  host = data.tfe_outputs.aks.values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.aks.values.cluster_ca_certificate)
  cluster_name = data.tfe_outputs.aks.values.cluster_name
  client_certificate = base64decode(data.tfe_outputs.aks.values.client_certificate)
  client_key = base64decode(data.tfe_outputs.aks.values.client_key)
  app_domain = format("%s-%s.%s", local.project_prefix, local.build_suffix, var.domain_name)
  xc_site_slo_ip = data.azurerm_network_interface.master-0.private_ip_address
} 