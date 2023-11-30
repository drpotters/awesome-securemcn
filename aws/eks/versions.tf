terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = ">= 4"
  }
}

#AWS Provider
provider "aws" {
  region = local.awsRegion
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}