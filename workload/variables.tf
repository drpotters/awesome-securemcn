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
variable "domain_name" {
  type        = string
  description = "The DNS domain name that will be used as common parent generated DNS name of loadbalancers."
  default     = "shared.acme.com"
}

# F5 XC specific values; these will be used in each cloud module
variable "f5xcTenant" {
  type        = string
  description = "The F5 XC tenant to use."
}
variable "namespace" {
  type        = string
  description = "The F5 XC and K8s namespace into which XC nodes, resources, and app workloads will be deployed."
}
variable "f5xc-sd-sa" {
  type        = string
  description = "Name of the K8s Service Account F5 XC uses for service discovery"
  default     = "f5xc-sd-serviceaccount"
}

# AWS specific vars - if these are not empty/null, AWS resources will be created
variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = null
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

# XC App Connect
#XC
variable "app_domain" {
  type        = string
  description = "FQDN for the app. If you have delegated domain `prod.example.com`, then your app_domain can be `<app_name>.prod.example.com`"
  default     = "arcadia-mcn.f5-cloud-demo.com"
}
#XC WAF
variable "xc_waf_blocking" {
  type        = string
  description = "Set XC WAF to Blocking(true) or Monitoring(false)"
  default     = "false"
}
#XC AI/ML Settings for MUD, APIP - NOTE: Only set if using AI/ML settings from the shared namespace
variable "xc_app_type" {
  type        = list
  description = "Set Apptype for shared AI/ML"
  default     = []
}
variable "xc_multi_lb" {
  type        = string
  description = "ML configured externally using app type feature and label added to the HTTP load balancer."
  default     = "false"
}
#XC API Protection and Discovery
variable "xc_api_disc" {
  type        = string
  description = "Enable API Discovery on single LB"
  default     = "false"
}
variable "xc_api_pro" {
  type        = string
  description = "Enable API Protection (Definition and Rules)"
  default     = "false"
}
variable "xc_api_spec" {
  type        = list
  description = "XC object store path to swagger spec ex: https://my.tenant.domain/api/object_store/namespaces/my-ns/stored_objects/swagger/file-name/v1-22-01-12"
  default     = null
}
#XC Bot Defense
variable "xc_bot_def" {
  type = string
  description = "Enable XC Bot Defense"
  default = "false"
}
#XC DDoS Protection
variable "xc_ddos_def" {
  type = string
  description = "Enable XC DDoS Protection"
  default = "false"
}
#XC DDoS Protection
variable "xc_ddos_pro" {
  type = string
  description = "Enable XC DDoS Protection"
  default = "false"
}
#XC Malicious User Detection
variable "xc_mud" {
  type        = string
  description = "Enable Malicious User Detection on single LB"
  default     = "false"
}