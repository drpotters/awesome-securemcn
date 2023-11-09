#TF Cloud
variable "tf_cloud_organization" {
  type = string
  description = "TF cloud org (Value set in TF cloud)"
}
#NIGNX
variable nginx_registry {
    type = string
    description = "NGINX docker regstery"
    default = "private-registry.nginx.com"
}
variable nginx_jwt {
    type = string
    description = "JWT for pulling NGINX image"
    default = "nginx_repo.jwt"
}
variable "ssh_key" {
  type        = string
  description = "Unneeded for NAP, only present for warning handling with TF cloud variable set"
}

# AWS specific vars - if these are not empty/null, AWS resources will be created
variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = null
}
# Common solution variables
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
  default     = "mcn-demo"
}

#AWS Variables
variable "aws_access_key" {
  description = "AWS API Programmatic Access Key"
  type = string
  default = ""
}
variable "aws_access_secret" {
  description = "AWS API Programmatic Key Secret"
  type = string
  default = ""
}