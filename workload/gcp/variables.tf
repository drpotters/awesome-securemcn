#TF Cloud
variable "tf_cloud_organization" {
  type = string
  description = "TF cloud org (Value set in TF cloud)"
}
variable "ssh_key" {
  type        = string
  description = "Unneeded for arcadia, only present for warning handling with TF cloud variable set"
}

# Common solution variables
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
  default     = "mcn-demo"
}

# F5 XC specific values; these will be used in each cloud module
variable "namespace" {
  type        = string
  description = "The F5 XC and K8s namespace into which XC nodes, resources, and app workloads will be deployed."
}

# AWS specific vars - if these are not empty/null, AWS resources will be created
variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = null
}

# GCP Specific vars - if these are not empty/null, GCP resources will be created
variable "gcpRegion" {
  type        = string
  default     = null
  description = "region where GCP resources will be deployed"
}

variable "gcpProjectId" {
  type        = string
  default     = null
  description = "gcp project id"
}

variable "f5xcCloudCredGCP" {
  type        = string
  default     = null
  description = "F5 XC Cloud Credential to use with GCP"
}

# App Workload specific
# (Optional) Private docker registry to pull container images
variable "use_private_registry" {
  type        = bool
  default     = false
  description = "Whether to use an optional private docker registry to pull the app workload container images"
}
variable "registry_server" {
  type = string
  default = "registry.gitlab.com"
  description = "FQDN of the docker registry server"
}
variable "registry_username" {
  type        = string
  default     = ""
  description = "Private docker registry acount username"
}
variable "registry_password" {
  type        = string
  default     = ""
  description = "Private docker registry account password"
}
variable "registry_email" {
  type        = string
  default     = ""
  description = "Private docker registry account email address"
}