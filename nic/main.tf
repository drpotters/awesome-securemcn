provider "aws" {
  region = local.awsRegion
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}
provider "kubernetes" {
    host = local.aws_host
    cluster_ca_certificate = base64decode(local.aws_cluster_ca_certificate)
    token = data.aws_eks_cluster_auth.auth.token
}
provider "helm" {
    kubernetes {
        host = local.aws_host
        cluster_ca_certificate = base64decode(local.aws_cluster_ca_certificate)
        token = data.aws_eks_cluster_auth.auth.token  
    }
}