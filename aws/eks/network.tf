

# Create Elastic IP
resource "aws_eip" "main" {
  tags = {
    resource_owner = local.resource_owner
    Name          = format("%s-eip-%s", var.projectPrefix, local.buildSuffix)
  }
}

# Create NAT Gateway
#resource "aws_nat_gateway" "main" {
#  allocation_id = aws_eip.main.id
#  subnet_id     = local.public_subnet_ids[0]
#
#  tags = {
#    resource_owner = local.resource_owner
#    Name          = format("%s-ngw-%s", var.projectPrefix, local.buildSuffix)
#  }
#}

module subnet_addrs {
  for_each        = toset(local.azs)
  source          = "hashicorp/subnets/cidr"
  version         = "1.0.0"
  base_cidr_block = cidrsubnet(local.eks_cidr,2,index(local.azs,each.key))
  networks        = [
    {
      name     = "eks-internal"
      new_bits = 1
    },
    {
      name     = "eks-external"
      new_bits = 1
    }
  ]
}

data "aws_subnet" "workload_subnet" {
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*workload-${local.buildSuffix}"]
  }
}

data "aws_subnet" "inside_subnet" {
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*inside-${local.buildSuffix}"]
  }
}

data "aws_subnet" "slo_subnet" {
  for_each          = {for i, az_name in local.azs: i => az_name}
  availability_zone = local.azs[each.key]
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = ["*vpc-${local.buildSuffix}"]
  }
}

resource "aws_subnet" "eks-internal" {
  for_each          = toset(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = module.subnet_addrs[each.key].network_cidr_blocks["eks-internal"]
  availability_zone = each.key
  tags              = {
    Name = format("%s-eks-int-subnet-%s",var.projectPrefix,each.key)
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                      = "1"
  }
}
resource "aws_subnet" "eks-external" {
  for_each          = toset(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = module.subnet_addrs[each.key].network_cidr_blocks["eks-external"]
  map_public_ip_on_launch = true
  availability_zone = each.key
  tags              = {
    Name = format("%s-eks-ext-subnet-%s",var.projectPrefix,each.key)
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    // "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/role/internal-elb"                = "1"
  }
}
#resource "aws_route_table" "main" {
#  vpc_id = local.vpc_id
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = aws_nat_gateway.main.id
#  }
#  tags = {
#    Name = format("%s-eks-rt-%s", var.projectPrefix, local.buildSuffix)
#  }
#}
#resource "aws_route_table_association" "internal-subnet-association" {
#  for_each       = nonsensitive(toset(local.azs))
#  subnet_id      = aws_subnet.eks-internal[each.key].id
#  route_table_id = aws_route_table.main.id
#}
resource "aws_route_table_association" "external-subnet-association" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.eks-external[each.key].id
  route_table_id = local.route_table_id
}



