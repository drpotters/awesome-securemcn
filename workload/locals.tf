locals {
# Common
  project_prefix = var.projectPrefix
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  app_domain = format("%s-%s.%s", local.project_prefix, local.build_suffix, var.domain_name)
  dns_origin_pool = local.aws_origin_nginx != "" ? true : false 


# AWS
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  aws_external_name = data.tfe_outputs.nic.values.external_name
  aws_region = var.awsRegion
  eks_host = data.tfe_outputs.eks.values.cluster_endpoint
  eks_cluster_ca_certificate = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
  eks_cluster_name = data.tfe_outputs.eks.values.cluster_name
  // origin_nginx = try(data.tfe_outputs.nap[0].values.external_name, data.tfe_outputs.nic[0].values.external_name, "")
  aws_origin_nginx = try (data.tfe_outputs.nic.values.external_name, "")
  // origin_server = "${coalesce(local.origin_bigip, local.origin_nginx)}"
  aws_origin_server = local.aws_origin_nginx
  // origin_port = try(data.tfe_outputs.nap[0].values.external_port, data.tfe_outputs.nic[0].values.external_port, "80")
  aws_origin_port = try(data.tfe_outputs.nic.values.external_port, "80")
  aws_service_name = format("%s-nic-%s-nginx-ingress-controller", var.projectPrefix, local.build_suffix)
  aws_service_endpoint_ip = data.tfe_outputs.aws-workload.values.service_endpoint_ip

# Azure
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  aks_host = data.tfe_outputs.aks.values.cluster_endpoint
  aks_cluster_ca_certificate = base64decode(data.tfe_outputs.aks.values.cluster_ca_certificate)
  aks_cluster_name = data.tfe_outputs.aks.values.cluster_name
  aks_client_certificate = base64decode(data.tfe_outputs.aks.values.client_certificate)
  aks_client_key = base64decode(data.tfe_outputs.aks.values.client_key)
  azure_service_endpoint_ip = data.tfe_outputs.azure-workload.values.service_endpoint_ip
  aks_origin_port = data.tfe_outputs.azure-workload.values.ingress_service_port
} 