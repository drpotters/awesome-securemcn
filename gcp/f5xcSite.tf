/* resource "volterra_gcp_vpc_site" "xc" {
  name      = format("%s-gcp-%s", var.projectPrefix, local.buildSuffix)
  namespace = "system"

  // One of the arguments from this list "default_blocked_services blocked_services" must be set
  default_blocked_services = true

  // One of the arguments from this list "cloud_credentials" must be set

  cloud_credentials {
    name      = var.f5xcCloudCredAWS
    tenant    = var.f5xcTenant
    namespace = "system"
  }

  gcp_region    = ["us-west1"]
  instance_type = ["n1-standard-4"]
  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  // One of the arguments from this list "ingress_gw ingress_egress_gw voltstack_cluster" must be set

  voltstack_cluster {
    // One of the arguments from this list "no_dc_cluster_group dc_cluster_group" must be set
    no_dc_cluster_group = true

    // One of the arguments from this list "no_forward_proxy active_forward_proxy_policies forward_proxy_allow_all" must be set
    no_forward_proxy = true
    gcp_certified_hw = "gcp-byol-voltstack-combo"

    gcp_zone_names = ["us-west1-a, us-west1-b, us-west1-c"]

    // One of the arguments from this list "no_global_network global_network_list" must be set
    // no_global_network = true
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

    // One of the arguments from this list "no_k8s_cluster k8s_cluster" must be set
    no_k8s_cluster = true

    // One of the arguments from this list "no_network_policy active_network_policies active_enhanced_firewall_policies" must be set
    no_network_policy = true
    node_number       = "1"

    // One of the arguments from this list "no_outside_static_routes outside_static_routes" must be set
    no_outside_static_routes = true

    site_local_network {
      // One of the arguments from this list "existing_network new_network_autogenerate new_network" must be set

      new_network_autogenerate {
        autogenerate = true
      }
    }

    site_local_subnet {
      // One of the arguments from this list "new_subnet existing_subnet" must be set

      new_subnet {
        primary_ipv4 = "10.3.0.0/16"
        subnet_name  = "subnet1-in-network1"
      }
    }

    // One of the arguments from this list "sm_connection_public_ip sm_connection_pvt_ip" must be set
    sm_connection_public_ip = true

    // One of the arguments from this list "default_storage storage_class_list" must be set
    default_storage = true
  }
} */

# Create a GCP VPC site
resource "volterra_gcp_vpc_site" "perimeter" {
  name        = format("%s-gcp-%s", var.projectPrefix, local.buildSuffix)
  namespace   = "system"
  description = format("GCP VPC Site (%s-%s)", var.projectPrefix, local.buildSuffix)
  annotations = local.volterra_common_annotations
  coordinates {
    latitude  = module.region_locations.lookup[var.gcpRegion].latitude
    longitude = module.region_locations.lookup[var.gcpRegion].longitude
  }
  cloud_credentials {
    name      = var.f5xcCloudCredGCP
    namespace = "system"
    tenant    = var.f5xcTenant
  }
  gcp_region              = var.gcpRegion
  instance_type           = "n1-standard-4"
  logs_streaming_disabled = true
  ssh_key                 = var.ssh_key
  ingress_egress_gw {
    gcp_certified_hw = "gcp-byol-multi-nic-voltmesh"
    node_number      = var.num_volterra_nodes
    gcp_zone_names   = local.zones
    #no_forward_proxy = true
    forward_proxy_allow_all  = false
    // no_global_network        = true
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
    no_network_policy        = true
    no_inside_static_routes  = true
    no_outside_static_routes = true
    inside_network {
      existing_network {
        name = module.inside.network_name
      }
    }
    inside_subnet {
      existing_subnet {
        subnet_name = module.inside.subnets_names[0]
      }
    }
    outside_network {
      existing_network {
        name = module.outside.network_name
      }
    }
    outside_subnet {
      existing_subnet {
        subnet_name = module.outside.subnets_names[0]
      }
    }
  }
  lifecycle {
    ignore_changes = [labels]
  }
  # These shouldn't be necessary, but lifecycle is flaky without them
  depends_on = [module.inside, module.outside]
}

resource "volterra_cloud_site_labels" "labels" {
  name  = volterra_gcp_vpc_site.perimeter.name
  site_type = "gcp_vpc_site"
  labels = merge(local.volterra_common_labels, var.commonSiteLabels)
  ignore_on_delete = true
}

# Instruct Volterra to provision the GCP VPC site
resource "volterra_tf_params_action" "perimeter" {
  site_name        = volterra_gcp_vpc_site.perimeter.name
  site_kind        = "gcp_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false
  # These shouldn't be necessary, but lifecycle is flaky without them
  depends_on = [module.inside, module.outside, volterra_gcp_vpc_site.perimeter]
}