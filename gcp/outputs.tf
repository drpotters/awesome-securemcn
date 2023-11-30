/* output "connection_helpers" {
  value       = jsonencode({ for k, v in module.workstation : k => jsondecode(v.connection_helpers) })
  description = <<EOD
A set of `gcloud` commands to connect to SSH, setup a forward-proxy, and to access
Code Server on each workstation, mapped by business unit.
EOD
}

*/

/* output "tf_output" {
  value       = volterra_tf_params_action.inside.tf_output
  description = "A record of what has been created by XC for the CE deployment"
} */

output "network_name_inside" {
  description = "The name for inside subnet"
  value = nonsensitive(module.inside.network_name)
}

output "network_name_outside" {
  description = "The name for outside subnet"
  value = nonsensitive(module.outside.network_name)
}

output "subnet_name_inside" {
  description = "The name for inside subnet"
  value = nonsensitive(module.inside.subnets_names[0])
}

output "subnet_name_outside" {
  description = "The name for outside subnet"
  value = nonsensitive(module.outside.subnets_names[0])
}

/* output "gcp_region" {
  description = "The the GCP resource is deployed to"
  value = var.gcpRegion
}

output "cidr_blocks" {
  description = "CIDR blocks used by GCP"
  value = {
      ce_sli_cidr      = var.business_units.bu21.cidr
      ce_slo_cidr      = var.outside_cidr[0]
      proxysubnet_cidr = var.outside_cidr[1]
  }
} */