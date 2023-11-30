############################ F5 XC AWS VPC Sites ############################

resource "volterra_aws_vpc_site" "xc" {
  name                    = format("%s-aws-%s", local.projectPrefix, local.buildSuffix)
  namespace               = "system"
  aws_region              = local.awsRegion
  instance_type           = "t3.xlarge"
  disk_size               = "80"
  ssh_key                 = var.ssh_id
  logs_streaming_disabled = true
  no_worker_nodes         = true

  # If CyberSec needs for the CE to be unreachable to the wide open Internet
  blocked_services {
    blocked_sevice {
      dns                 = true
      network_type        = "VIRTUAL_NETWORK_SITE_LOCAL"
      ssh                 = false
      web_user_interface  = true
    }
  }
  #default_blocked_services = { }

  aws_cred {
    name      = local.f5xcCloudCredAWS
    namespace = "system"
    tenant    = local.xc_tenant
  }

  ingress_egress_gw {
    aws_certified_hw         = "aws-byol-multi-nic-voltmesh"
    forward_proxy_allow_all  = true
    no_network_policy        = true
    no_inside_static_routes  = true
    
    outside_static_routes {
      static_route_list {
          custom_static_route {
            subnets {
              ipv4 {
                prefix = local.aws_cidr_prefix_split[0]
                plen = local.aws_cidr_prefix_split[1]
              }
            }
            nexthop {
              type = "NEXT_HOP_USE_CONFIGURED"
              nexthop_address {
                ipv4 {
                  addr = cidrhost(local.aws_cidr[0].publicSubnets[0],1)
                }
              }
            }
            attrs = [
             "ROUTE_ATTR_INSTALL_FORWARDING",
             "ROUTE_ATTR_INSTALL_HOST"
            ]
          }
      }
    }
    
    active_enhanced_firewall_policies {
      enhanced_firewall_policies {
        name = "${local.projectPrefix}-${local.buildSuffix}-enh-fw-pol"
      }
    }
    
    global_network_list {
        global_network_connections {
          slo_to_global_dr {
            global_vn {
              name = data.tfe_outputs.root.values.xc_global_vn
              namespace = "system"
            }
          }
        }
    }

    az_nodes {
      aws_az_name            = local.awsAz1
      reserved_inside_subnet = false
      disk_size              = 100

      inside_subnet {
        existing_subnet_id = aws_subnet.sli.id
      }
      outside_subnet {
        existing_subnet_id = module.vpc.public_subnets[0]
      }
      workload_subnet {
        existing_subnet_id = aws_subnet.workload.id
      }
    }

    # inside_static_routes {
    #   static_route_list {
    #     custom_static_route {
    #       subnets {
    #         ipv4 {
    #           prefix = "10.1.0.0"
    #           plen   = "16"
    #         }
    #       }
    #       nexthop {
    #         type = "NEXT_HOP_USE_CONFIGURED"
    #         nexthop_address {
    #           ipv4 {
    #             addr = "10.1.20.1"
    #           }
    #         }
    #       }
    #       attrs = [
    #         "ROUTE_ATTR_INSTALL_FORWARDING",
    #         "ROUTE_ATTR_INSTALL_HOST"
    #       ]
    #     }
    #   }
    # }
  }

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.xc.name
  site_type        = "aws_vpc_site"
  labels           = merge(local.f5xcCommonLabels)
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "apply" {
  site_name        = volterra_aws_vpc_site.xc.name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_aws_vpc_site.xc]
}