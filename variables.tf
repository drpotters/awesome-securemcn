# Common solution variables
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
  default     = "mcn-demo"
}

variable "buildSuffix" {
  type        = string
  default     = null
  description = "unique build suffix for resources; will be generated if empty or null"
}

variable "resourceOwner" {
  type        = string
  description = "owner of the deployment, for tagging purposes"
  default     = null
}

variable "domain_name" {
  type        = string
  default     = "shared.acme.com"
  description = "The DNS domain name that will be used as common parent generated DNS name of loadbalancers. Default is 'shared.acme.com'."
}

# F5 XC specific values; these will be used in each cloud module
variable "namespace" {
  type        = string
  description = "The F5 XC namespace into which XC nodes and resources will be managed."
}

variable "f5xcTenant" {
  type        = string
  description = "The F5 XC tenant to use."
}

variable "ssh_key" {
  type        = string
  default     = ""
  description = "An optional SSH key to add to nodes."
}

# AWS specific vars - if these are not empty/null, AWS resources will be created
variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = null
}

variable "f5xcCloudCredAWS" {
  type        = string
  default     = null
  description = "F5 XC Cloud Credential to use with AWS"
}
variable "awsAz1" {
  description = "Availability Zone #"
  type        = string
  default = "az1"
}
variable "awsAz2" {
  description = "Availability Zone #"
  type        = string
  default = "az2"
}

# Azure specific vars - if these are not empty/null, Azure resources will be created
variable "azureLocation" {
  type        = string
  default     = null
  description = "location where Azure resources are deployed (abbreviated Azure Region name)"
}

variable "f5xcCloudCredAzure" {
  type        = string
  default     = null
  description = "F5 XC Cloud Credential to use with Azure"
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

variable "commonSiteLabels" {
  type        = map
  default     = null
  description = "A common collection of labels (tags) to be assigned to each CE Site"
}

variable "commonClientIP" {
  type        = string
  default     = null
  description = "Client IP is used for security access groups"
}

#TF Cloud
variable "tf_cloud_organization" {
  type = string
  description = "TF cloud org (Value set in TF cloud)"
}

# App Workload specific
# (Optional) Private docker registry to pull container images
variable "use_private_registry" {
  type        = bool
  default     = false
  description = "Whether to use an optional private docker registry to pull the app workload container images"
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