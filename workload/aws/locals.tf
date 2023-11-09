locals {
  project_prefix = var.projectPrefix
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  // external_name = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
  external_name = data.tfe_outputs.nic.values.external_name
  aws_region = var.awsRegion
  host = data.tfe_outputs.eks.values.cluster_endpoint
  cluster_ca_certificate = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
  cluster_name = data.tfe_outputs.eks.values.cluster_name
  // origin_nginx = try(data.tfe_outputs.nap[0].values.external_name, data.tfe_outputs.nic[0].values.external_name, "")
  origin_nginx = try (data.tfe_outputs.nic.values.external_name, "")
  // origin_server = "${coalesce(local.origin_bigip, local.origin_nginx)}"
  origin_server = local.origin_nginx
  // origin_port = try(data.tfe_outputs.nap[0].values.external_port, data.tfe_outputs.nic[0].values.external_port, "80")
  origin_port = try(data.tfe_outputs.nic.values.external_port, "80")
  dns_origin_pool = local.origin_nginx != "" ? true : false 
  kubeconfig_name = format("%s-%s-aws-kubeconfig", var.projectPrefix, data.tfe_outputs.root.values.buildSuffix)
  kubeconfig_data = nonsensitive(templatefile("templates/kubeconfig.tpl", {
    kubeconfig_name                   = local.kubeconfig_name
    endpoint                          = data.tfe_outputs.eks.values.cluster_endpoint
    cluster_auth_base64               = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
    secret_token                      = kubernetes_secret_v1.f5xc-sd-sa-secret.data.token
  }))
  service_name = format("%s-nic-%s-nginx-ingress-controller", var.projectPrefix, local.build_suffix)
  service_endpoint_ip = join("", flatten(data.kubernetes_endpoints_v1.origin-pool-k8s-service.subset[*].address[*].ip))
  app_domain = format("%s-%s.%s", var.projectPrefix, local.build_suffix, var.domain_name)
  xc_site_slo_ip = data.tfe_outputs.aws.values.site_slo_ip
} 