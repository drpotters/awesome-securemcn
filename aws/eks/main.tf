#Main
#AWS Provider
provider "aws" {
  region = local.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_access_secret
}

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
}
