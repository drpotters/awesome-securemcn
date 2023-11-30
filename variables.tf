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

variable "app_domain" {
  type        = string
  default     = "mcn-demo.int"
  description = "The DNS domain name that will be used as common parent generated DNS name of loadbalancers. Default is 'shared.acme.com'."
}

# F5 XC specific values; these will be used in each cloud module
variable "namespace" {
  type        = string
  description = "The F5 XC namespace into which XC nodes and resources will be managed."
}

variable "xc_tenant" {
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
  default     = "az1"
}
variable "awsAz2" {
  description = "Availability Zone #"
  type        = string
  default     = "az2"
}
variable "aws_cidr" {
  type = list(object({
    vpcCidr         = string,
    publicSubnets   = list(string),
    sliSubnets      = list(string),
    workloadSubnets = list(string),
    privateSubnets  = list(string)
  }))
  default = [{
    vpcCidr         = "10.1.0.0/16",
    publicSubnets   = ["10.1.10.0/24", "10.1.110.0/24"],
    sliSubnets      = ["10.1.20.0/24", "10.1.120.0/24"],
    workloadSubnets = ["10.1.30.0/24", "10.2.130.0/24"],
    privateSubnets  = ["10.1.52.0/24", "10.1.152.0/24"]
  }]
}

# Azure specific vars - if these are not empty/null, Azure resources will be created
variable "azure_cidr" {
  type = list(object({
    vnet = list(object({
      vnetCidr = string
    })),
    subnets = list(object({
      public              = string
      sli                 = string
      workload            = string
      AzureFirewallSubnet = string
      private             = string
    }))
  }))
  default = [{
      vnet = [{
        vnetCidr = "10.2.0.0/16"
      }],
      subnets = [{
        public              = "10.2.10.0/24"
        sli                 = "10.2.20.0/24"
        workload            = "10.2.30.0/24"
        AzureFirewallSubnet = "10.2.40.0/24"
        private             = "10.2.52.0/24"
      }]
  }]
}

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
variable "gcp_cidr" {
  type = list(object({
    network     = string,
    sli         = string,
    slo         = string,
    proxysubnet = string
  }))
  default = [{
    network     = "", // GCP doesn't require a base network CIDR
    sli         = "10.3.0.0/16",
    slo         = "100.64.96.0/22",
    proxysubnet = "100.64.100.0/24"
  }]
}

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
  type        = map(any)
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
  type        = string
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