locals {
  projectPrefix = data.tfe_outputs.root.values.projectPrefix
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  resourceOwner = data.tfe_outputs.root.values.resourceOwner
  awsRegion = data.tfe_outputs.root.values.awsRegion
  aws_cidr = data.tfe_outputs.root.values.aws_cidr

  awsAz1 = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2 = var.awsAz2 != null ? var.awsAz2 : data.aws_availability_zones.available.names[1]
  azs = tolist([local.awsAz1, local.awsAz2])
  vpc_id  = data.tfe_outputs.aws.values.vpcId
#  vpc_main_route_table_id = var.route_table_id
#  public_subnet_ids = var.publicSubnets
  eks_cidr = nonsensitive(local.aws_cidr[0].privateSubnets[1])
#  internal_sg_id = data.tfe_outputs.infra.values.internal_sg_id
  cluster_name = format("%s-%s-eks-cluster", local.projectPrefix, local.buildSuffix)
  route_table_id = data.tfe_outputs.aws.values.route_table_id
}
