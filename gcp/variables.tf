#TF Cloud
variable "tf_cloud_organization" {
  type = string
  description = "TF cloud org (Value set in TF cloud)"
}

/*
# project
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
}
variable "gcpRegion" {
  type        = string
  description = "region where gke is deployed"
}
variable "gcpProjectId" {
  type        = string
  description = "gcp project id"
}

variable "resourceOwner" {
  type        = string
  description = "owner of the deployment, for tagging purposes"
}

variable "business_units" {
  type = map(object({
    cidr        = string
    mtu         = number
    workstation = bool
  }))
  default = {
    bu21 = {
      cidr        = "10.3.0.0/16"
      mtu         = 1460
      workstation = true
    }
#    bu22 = {
#      cidr        = "10.3.0.0/16"
#      mtu         = 1460
#      workstation = false
#    }
#    bu23 = {
#      cidr        = "10.3.0.0/16"
#      mtu         = 1460
#      workstation = false
#    }
  }
  description = <<EOD
The set of VPCs to create with overlapping CIDRs.
EOD
}

variable "outside_cidr" {
  type        = list
  default     = [ "100.64.96.0/22", "100.64.100.0/24" ]
  description = <<EOD
The CIDR to assign to shared outside VPC and to the proxy-only subnet for ingress
load balancing. Default is '100.64.96.0/22' and '100.64.100.0/24'.
EOD
}
*/

variable "domain_name" {
  type        = string
  description = <<EOD
The DNS domain name that will be used as common parent generated DNS name of
loadbalancers.
EOD
  default     = "shared.acme.com"
}

variable "num_servers" {
  type        = number
  default     = 1
  description = <<EOD
The number of webserver instances to launch in each business unit spoke. Default
is 2.
EOD
}

variable "num_volterra_nodes" {
  type        = number
  default     = 1
  description = <<EOD
The number of Volterra gateway instances to launch in each business unit spoke.
Default is 1.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional list of labels to apply to GCP resources.
EOD
}
variable "commonSiteLabels" {
  type        = map(string)
  default     = {} 
  description = "An optional list of labels to apply to all CE Sites."
} 

/* variable "commonClientIP" {
  type        = string
  default     = null
  description = "Client IP is used for security access groups"
}

variable "namespace" {
  type        = string
  description = <<EOD
The Volterra namespace into which Volterra resources will be managed.
EOD
}

variable "xc_tenant" {
  type        = string
  description = <<EOD
The Volterra tenant to use.
EOD
}
*/

variable "ssh_id" {
  type        = string
  default     = ""
  description = <<EOD
An optional SSH key to add to Volterra nodes.
EOD
}

/*
variable "f5xcCloudCredGCP" {
  description = "Name of the Volterra cloud credentials to use with GCP VPC sites"
  type        = string
}
*/