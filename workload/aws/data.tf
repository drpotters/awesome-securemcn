terraform {
  cloud {
    organization = "example-org-fa8f78"
    workspaces {
      name = "xcmcn-ce-aws-workload"
    }
  }
}

data "tfe_outputs" "root" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-root"
}
data "tfe_outputs" "aws" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-aws"
}
data "tfe_outputs" "eks" {
  organization = "example-org-fa8f78"
  workspace = "xcmcn-ce-aws-eks"
}
data "tfe_outputs" "nic" {
  organization = var.tf_cloud_organization
  workspace = "xcmcn-ce-nic"
}

data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}

data "kubernetes_endpoints_v1" "origin-pool-k8s-service" {
  metadata {
    name = local.service_name
    namespace = "nginx-ingress"
  }
}
