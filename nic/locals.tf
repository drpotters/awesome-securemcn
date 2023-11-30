locals {
  aws_host = data.tfe_outputs.eks.values.cluster_endpoint
  aws_cluster_ca_certificate = data.tfe_outputs.eks.values.kubeconfig-certificate-authority-data
  aws_cluster_name = data.tfe_outputs.eks.values.cluster_name

  projectPrefix = data.tfe_outputs.root.values.projectPrefix
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  resourceOwner = data.tfe_outputs.root.values.resourceOwner
  commonClientIP = data.tfe_outputs.root.values.commonClientIP
  f5xcCloudCredAWS = data.tfe_outputs.root.values.f5xcCloudCredAWS
  awsRegion = data.tfe_outputs.root.values.awsRegion
  aws_cidr = data.tfe_outputs.root.values.aws_cidr
}