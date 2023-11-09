locals {
  project_prefix = var.projectPrefix
  build_suffix = data.tfe_outputs.root.values.buildSuffix
  aws_region = var.awsRegion
  host = data.tfe_outputs.eks.values.cluster_endpoint
  cluster_ca_certificate = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
  cluster_name = data.tfe_outputs.eks.values.cluster_name
} 