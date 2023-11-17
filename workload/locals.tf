locals {
  # AWS
  project_prefix = var.projectPrefix
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  external_name = data.tfe_outputs.nic.values.external_name
  aws_region = var.awsRegion
  eks_host = data.tfe_outputs.eks.values.cluster_endpoint
  eks_cluster_ca_certificate = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
  eks_cluster_name = data.tfe_outputs.eks.values.cluster_name
  // origin_nginx = try(data.tfe_outputs.nap[0].values.external_name, data.tfe_outputs.nic[0].values.external_name, "")
  origin_nginx = try (data.tfe_outputs.nic.values.external_name, "")
  // origin_server = "${coalesce(local.origin_bigip, local.origin_nginx)}"
  aws_origin_server = local.origin_nginx
  // origin_port = try(data.tfe_outputs.nap[0].values.external_port, data.tfe_outputs.nic[0].values.external_port, "80")
  aws_origin_port = try(data.tfe_outputs.nic.values.external_port, "80")
  dns_origin_pool = local.origin_nginx != "" ? true : false 
  kubeconfig_name = format("%s-%s-aws-kubeconfig", var.projectPrefix, data.tfe_outputs.root.values.buildSuffix)
  kubeconfig_data = nonsensitive(templatefile("templates/kubeconfig.tpl", {
    kubeconfig_name                   = local.kubeconfig_name
    endpoint                          = data.tfe_outputs.eks.values.cluster_endpoint
    cluster_auth_base64               = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
    secret_token                      = kubernetes_secret_v1.f5xc-sd-sa-secret.data.token
  }))
  aws_service_name = format("%s-nic-%s-nginx-ingress-controller", var.projectPrefix, local.build_suffix)
  aws_service_endpoint_ip = join("", flatten(data.kubernetes_endpoints_v1.origin-pool-k8s-service.subset[*].address[*].ip))
  app_domain = format("%s-%s.%s", var.projectPrefix, local.build_suffix, var.domain_name)
  aws_xc_site_slo_ip = data.tfe_outputs.aws.values.site_slo_ip

  # Azure
  aks_host = data.tfe_outputs.aks.values.cluster_endpoint
  aks_cluster_ca_certificate = base64decode(data.tfe_outputs.aks.values.cluster_ca_certificate)
  aks_cluster_name = data.tfe_outputs.aks.values.cluster_name
  aks_client_certificate = base64decode(data.tfe_outputs.aks.values.client_certificate)
  aks_client_key = base64decode(data.tfe_outputs.aks.values.client_key)
  aks_origin_port = kubernetes_service.app2.spec[0].port[0].port
  azure_service_endpoint_ip = kubernetes_service.app2.status[0].load_balancer[0].ingress[0].ip
  azure_xc_site_slo_ip = data.azurerm_network_interface.master-0.private_ip_address 

  # GCP
  gke_host = "https://${data.tfe_outputs.gke.values.kubernetes_cluster_host}"
  gke_cluster_ca_certificate = data.tfe_outputs.gke.values.kubernetes_cluster_ca_certificate
  gke_cluster_name = data.tfe_outputs.gke.values.kubernetes_cluster_name
  gke_token = data.google_client_config.default.access_token
  gke_load_balancer_ip = kubernetes_ingress_v1.app3-ingress.status[0].load_balancer[0].ingress[0].ip
}