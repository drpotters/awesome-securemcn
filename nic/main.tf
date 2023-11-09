provider "aws" {
  region = var.awsRegion
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}
provider "kubernetes" {
    host = local.host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token = data.aws_eks_cluster_auth.auth.token
}
provider "helm" {
    kubernetes {
        host = local.host
        cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
        token = data.aws_eks_cluster_auth.auth.token  
    }
}