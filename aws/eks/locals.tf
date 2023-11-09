locals {
  resource_owner = var.resourceOwner
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  aws_region = var.awsRegion
  azs = tolist([var.awsAz1, var.awsAz2])
  vpc_id  = data.tfe_outputs.aws.values.vpcId
#  vpc_main_route_table_id = var.route_table_id
#  public_subnet_ids = var.publicSubnets
  eks_cidr = var.privateSubnets[0]
#  internal_sg_id = data.tfe_outputs.infra.values.internal_sg_id
  cluster_name = format("%s-eks-cluster-%s", var.projectPrefix, local.buildSuffix)
  route_table_id = data.tfe_outputs.aws.values.route_table_id
}
