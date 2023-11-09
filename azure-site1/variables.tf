variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
}
variable "resourceOwner" {
  type        = string
  description = "name of the person or customer running the solution"
}
variable "vnetCidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR IP Address range of the VNet"
}
variable "subnetPrefixes" {
  type        = list(any)
  default     = ["10.2.10.0/24", "10.2.20.0/24", "10.2.52.0/24", "10.2.30.0/24", "10.2.40.0/24"]
  description = "Subnet address prefixes"
}
variable "subnetNames" {
  type        = list(any)
  default     = ["public", "sli", "private", "workload", "AzureFirewallSubnet"]
  description = "Subnet names"
}
variable "webapp_image_offer_name" {
  type        = string
  default     = "0001-com-ubuntu-server-focal"
  description = "Offer name of marketplace image to find correct web app (Ubuntu) for region"
}
variable "public_address" {
  type        = bool
  default     = true
  description = "If true, an ephemeral public IP address will be assigned to the webserver. Default value is 'false'. "
}
variable "azureLocation" {
  type        = string
  description = "location where Azure resources are deployed (abbreviated Azure Region name)"
}
variable "azureZones" {
  type        = list(any)
  description = "The list of availability zones in a region"
  default     = [1, 2, 3]
}
variable "adminAccountName" {
  type        = string
  description = "admin account name used with instance"
  default     = "ubuntu"
}
variable "ssh_key" {
  type        = string
  description = "public key used for authentication in ssh-rsa format"
}
variable "f5xcTenant" {
  type        = string
  description = "Tenant of F5 XC"
}
variable "f5xcCloudCredAzure" {
  type        = string
  description = "Name of the F5 XC cloud credentials"
}
variable "namespace" {
  type        = string
  description = "F5 XC application namespace"
}
variable "domain_name" {
  type        = string
  description = "The DNS domain name that will be used as common parent generated DNS name of loadbalancers."
  default     = "shared.acme.com"
}
variable "labels" {
  type        = map(string)
  default     = {}
  description = "An optional list of labels to apply to Azure resources."
}
variable "commonSiteLabels" {
  type        = map(string)
  default     = {} 
  description = "An optional list of labels to apply to all CE Sites."
} 
variable "commonClientIP" {
  type        = string
  default     = null
  description = "Client IP is used for security access groups"
}
variable "instanceType" {
  type        = string
  description = "instance type for virtual machine"
  default     = "Standard_B2ms"
}

# Unused
variable "f5xcCloudCredGCP" {
  description = "Name of the Volterra cloud credentials to use with GCP VPC sites"
  type        = string
}
variable "gcpProjectId" {
  type        = string
  description = "gcp project id"
}
