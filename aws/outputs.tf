output "vpcId" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
output "webserver_private_ip" {
  value       = aws_instance.webserver.private_ip
  description = "Private IP address of web server"
}
output "webserver_public_ip" {
  value       = aws_eip.webserver.public_ip
  description = "Public IP address of web server"
}
output "webserver_public_dns" {
  value       = aws_eip.webserver.public_dns
  description = "Public DNS name of web server"
}
output "route_table_id" {
  description = "The main table id to attach to subnets that belong to EKS"
  value = module.vpc.public_route_table_ids[0]
}
output "site_name" {
  description = "The name of the site in F5 XC"
  value = nonsensitive(volterra_aws_vpc_site.xc.name)
}
output "site_slo_ip" {
  description = "IP belonging to the Site Local Outside interface"
  value = data.aws_network_interface.xc_slo.private_ip
}

output "site_slo_eni" {
  description = "ENI ID belonging to the Site Local Outside interface"
  value = data.aws_network_interface.xc_slo.id
}
# Uncomment as needed
/*
output "tf_output" {
  value       = volterra_tf_params_action.apply.tf_output
  description = "Useful info when debugging - display all the resources XC creates for the CE in public cloud "
}
*/