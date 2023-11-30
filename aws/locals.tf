locals {
  projectPrefix = data.tfe_outputs.root.values.projectPrefix
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  resourceOwner = data.tfe_outputs.root.values.resourceOwner
  commonClientIP = data.tfe_outputs.root.values.commonClientIP
  f5xcCloudCredAWS = data.tfe_outputs.root.values.f5xcCloudCredAWS
  awsRegion = data.tfe_outputs.root.values.awsRegion
  aws_cidr = data.tfe_outputs.root.values.aws_cidr
  azure_cidr = data.tfe_outputs.root.values.azure_cidr
  gcp_cidr = data.tfe_outputs.root.values.gcp_cidr
  cluster_name = format("%s-%s-eks-cluster", local.projectPrefix, local.buildSuffix)
  aws_cidr_prefix_split = split("/",local.aws_cidr[0].vpcCidr)

  xc_tenant = data.tfe_outputs.root.values.xc_tenant
  namespace = data.tfe_outputs.root.values.namespace

  awsAz1 = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2 = var.awsAz2 != null ? var.awsAz2 : data.aws_availability_zones.available.names[1]
  awsAz3 = var.awsAz3 != null ? var.awsAz3 : data.aws_availability_zones.available.names[2]

  awsCommonLabels = merge(var.awsLabels, {})
  f5xcCommonLabels = merge(var.labels, {
    demo     = "f5xc-mcn"
    owner    = local.resourceOwner
    prefix   = local.projectPrefix
    suffix   = local.buildSuffix
    platform = "aws"
    },
    var.commonSiteLabels
  )
}