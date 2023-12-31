terraform {
  required_version = ">= 0.14.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    volterra = {
      source  = "volterraedge/volterra"
    }
  }
}

provider "volterra" {
  timeout = "90s"
}

provider "google" {
}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.zones.names
  keepers = {
    gcpProjectId = local.gcpProjectId
  }
}

/*
# Service account to use with Workstation VMs
module "workstation_sa" {
  source       = "./modules/google-sa"
  // version      = ">= 4.0.2"
  project_id   = local.gcpProjectId
  prefix       = local.projectPrefix
  names        = [format("workstation-%s", local.buildSuffix)]
  descriptions = [format("Workstation service account (%s-%s)", local.projectPrefix, local.buildSuffix)]
  project_roles = [
    "${local.gcpProjectId}=>roles/logging.logWriter",
    "${local.gcpProjectId}=>roles/monitoring.metricWriter",
    "${local.gcpProjectId}=>roles/monitoring.viewer",
    "${local.gcpProjectId}=>roles/compute.osLogin",
  ]
  generate_keys = false
}

# Service account to use with Webserver VMs
module "webserver_sa" {
  source       = "./modules/google-sa"
  // version      = ">= 4.0.2"
  project_id   = local.gcpProjectId
  prefix       = local.projectPrefix
  names        = [format("webserver-%s", local.buildSuffix)]
  descriptions = [format("Webserver service account (%s-%s)", local.projectPrefix, local.buildSuffix)]
  project_roles = [
    "${local.gcpProjectId}=>roles/logging.logWriter",
    "${local.gcpProjectId}=>roles/monitoring.metricWriter",
    "${local.gcpProjectId}=>roles/monitoring.viewer",
  ]
  generate_keys = false
}
*/
# Create an inside VPC for each business unit, with a single regional subnet in each
module "inside" {
  source                                 = "./modules/google-network"
  // version                                = ">= 7.3.0"
  project_id                             = local.gcpProjectId
  network_name                           = format("%s-%s-inside", local.projectPrefix, local.buildSuffix)
  description                            = format("Shared inside VPC (%s-%s)", local.projectPrefix, local.buildSuffix)
  auto_create_subnetworks                = false
  delete_default_internet_gateway_routes = false
  mtu                                    = "1460"
  routing_mode                           = "REGIONAL"
  subnets = [
    {
      subnet_name           = format("%s-%s-inside", local.projectPrefix, local.buildSuffix)
      subnet_ip             = local.gcp_cidr[0].sli
      subnet_region         = local.gcpRegion
      subnet_private_access = false
    }
  ]
}

# Create a single outside VPC with a single regional subnet
module "outside" {
  // source                                 = "terraform-google-modules/network/google"
  source                                 = "./modules/google-network"
  // version                                = ">= 7.3.0"
  project_id                             = local.gcpProjectId
  network_name                           = format("%s-%s-outside", local.projectPrefix, local.buildSuffix)
  description                            = format("Shared outside VPC (%s-%s)", local.projectPrefix, local.buildSuffix)
  auto_create_subnetworks                = false
  delete_default_internet_gateway_routes = false
  mtu                                    = 1460
  routing_mode                           = "REGIONAL"
  subnets = [
    {
      subnet_name           = format("%s-%s-outside", local.projectPrefix, local.buildSuffix)
      subnet_ip             = local.gcp_cidr[0].slo
      subnet_region         = local.gcpRegion
      subnet_private_access = true
    },
    # Subnet designated to internal load balancing
    {
      subnet_name           = format("%s-%s-proxy-only", local.projectPrefix, local.buildSuffix)
      subnet_ip             = local.gcp_cidr[0].proxysubnet
      subnet_region         = local.gcpRegion
      subnet_private_access = false
      purpose = "REGIONAL_MANAGED_PROXY"
      role = "ACTIVE"
    }
  ]
  firewall_rules = [
    {
      name		= "allow-proxy-subnet-ingress"
      direction		= "INGRESS"
      ranges		= [ local.gcp_cidr[0].slo ]
      allow = [{
        protocol = "all"
        ports = []
      }]
    },
    {
      name		= "allow-remote-internal-networks-ingress"
      direction		= "INGRESS"
      ranges		= [ "10.0.0.0/8" ]
      allow = [{
        protocol = "all"
        ports = []
      }]      
    },
    {
      name		= "allow-health-checks"
      direction		= "INGRESS"
      // Health Check sources for External and Global LB resources
      ranges		= [ "35.191.0.0/16", "130.211.0.0/22" ]
      allow = [{
        protocol = "all"
        ports = []
      }]         
    }

  ]
}
/*
# Create a self-signed TLS certificate for workstations
module "workstation_tls" {
  source                  = "./modules/google/terraform/tls"
  gcpProjectId            = local.gcpProjectId
  secret_manager_key_name = format("%s-workstation-tls-%s", local.projectPrefix, local.buildSuffix)
  secret_accessors = [
    format("serviceAccount:%s", local.workstation_sa),
  ]
}

# Launch a Workstation VM (forward-proxy, ssh jumphost) on inside network of any
# business unit that has set the 'workstation' flag to true.
module "workstation" {
  for_each        = { for k, v in var.business_units : k => v if v.workstation }
  source          = "./modules/google/terraform/workstation"
  projectPrefix   = local.projectPrefix
  buildSuffix     = local.buildSuffix
  gcpProjectId    = local.gcpProjectId
  gcpRegion       = local.gcpRegion
  resourceOwner   = var.resourceOwner
  name            = format("%s-%s-workstation-%s", local.projectPrefix, each.key, local.buildSuffix)
  subnet          = module.inside[each.key].subnets_self_links[0]
  zone            = local.zones[0]
  labels          = local.gcp_common_labels
  service_account = local.workstation_sa
  tls_secret_key  = module.workstation_tls.tls_secret_key
  # Not using a NAT on the BU spokes, and Volterra gateway takes too long to
  # bootstrap; make sure the workstation gets a public address so it can pull
  # required packages and secrets.
  public_address = true
  depends_on = [
    module.workstation_sa,
    #  volterra_gcp_vpc_site.inside,
    #  volterra_tf_params_action.inside,
  ]
}

# Create a TLS certificate and key pair for webservers
module "webserver_tls" {
  source                  = "./modules/google/terraform/tls"
  gcpProjectId            = local.gcpProjectId
  secret_manager_key_name = format("%s-webserver-tls-%s", local.projectPrefix, local.buildSuffix)
  domain_name             = var.domain_name
  secret_accessors = [
    format("serviceAccount:%s", local.webserver_sa)
  ]
}

# Launch `var.num_servers` webserver VMs on the inside network of every business
# unit. These will be the sources for origin pools in each business unit.
module "webservers" {
  for_each = { for ws in setproduct(keys(var.business_units), range(0, var.num_servers)) : join("", ws) => {
    name   = format("%s-%s-web-%s-%d", local.projectPrefix, ws[0], local.buildSuffix, tonumber(ws[1]) + 1)
    subnet = module.inside[ws[0]].subnets_self_links[0]
    zone   = element(local.zones, index(keys(var.business_units), ws[0]) * var.num_servers + tonumber(ws[1]))
  } }
  source          = "./modules/google/terraform/backend"
  name            = each.value.name
  projectPrefix   = local.projectPrefix
  buildSuffix     = local.buildSuffix
  gcpProjectId    = local.gcpProjectId
  resourceOwner   = var.resourceOwner
  service_account = local.webserver_sa
  subnet          = each.value.subnet
  zone            = each.value.zone
  labels          = local.gcp_common_labels
  tls_secret_key  = module.webserver_tls.tls_secret_key
  # Not using a NAT on the BU spokes, and Volterra gateway takes too long to
  # bootstrap; make sure the webservers get public addresses so they can pull
  # required packages and secrets.
  public_address = true
  depends_on = [
    module.webserver_sa,
    # volterra_gcp_vpc_site.inside,
    # volterra_tf_params_action.inside,
  ]
}

# Allow ingress to webservers from any VM in the inside CIDR
resource "google_compute_firewall" "inside" {
  for_each  = var.business_units
  project   = local.gcpProjectId
  name      = format("%s-allow-all-%s-%s", local.projectPrefix, each.key, local.buildSuffix)
  network   = module.inside[each.key].network_self_link
  direction = "INGRESS"
  source_ranges = [
    each.value.cidr,
  ]
  target_service_accounts = [
    local.webserver_sa,
  ]
  allow {
    protocol = "TCP"
    ports = [
      80,
      443,
    ]
  }
} */

# Import helper module to determine approximate latitude/longitude of GCP regions
module "region_locations" {
  source = "git::https://github.com/memes/terraform-google-volterra//modules/region-locations?ref=0.3.1"
}

/*
# Distributed Cloud Section

# Define health checks for the origin pools; HTTP to 80
resource "volterra_healthcheck" "inside" {
  for_each    = var.business_units
  name        = format("%s-%s-%s", local.projectPrefix, each.key, local.buildSuffix)
  namespace   = var.namespace
  description = format("HTTP healthcheck for service in %s (%s-%s)", each.key, local.projectPrefix, local.buildSuffix)
  labels = merge(var.labels, {
    bu     = each.key
    demo   = "multi-cloud-connectivity-volterra"
    prefix = local.projectPrefix
    suffix = local.buildSuffix
  })
  healthy_threshold   = 1
  interval            = 15
  timeout             = 2
  unhealthy_threshold = 2
  http_health_check {
    use_origin_server_name = true
    path                   = "/"
  }

  depends_on = [
    google_compute_firewall.inside
  ]
}

# Define an origin pool for each business unit that contains the webservers
# launched on the inside network.
resource "volterra_origin_pool" "inside" {
  for_each               = var.business_units
  name                   = format("%s-%s-app-%s", local.projectPrefix, each.key, local.buildSuffix)
  namespace              = var.namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  labels = merge(local.volterra_common_labels, {
    bu = each.key
  })
  annotations = local.volterra_common_annotations
  # TODO: @memes - webserver supports TLS, and is deployed by default with
  # self-signed certs; try to enable TLS for the demo?
  port   = 80
  no_tls = true
  dynamic "origin_servers" {
    for_each = [for ws in setproduct([each.key], range(0, var.num_servers)) : module.webservers[join("", ws)].addresses.private]
    content {
      private_ip {
        ip = origin_servers.value
        site_locator {
          site {
            tenant    = var.xc_tenant
            namespace = volterra_gcp_vpc_site.inside[each.key].namespace
            name      = volterra_gcp_vpc_site.inside[each.key].name
          }
        }
        inside_network = true
      }
      labels = merge(local.volterra_common_labels, {
        bu = each.key
      })
    }
  }
}

# Define a load balancer for each app in the business units. VIP will be
# advertised to virtual site, so all Volterra gateways can proxy to the true
# source.
resource "volterra_http_loadbalancer" "inside" {
  for_each    = var.business_units
  name        = format("%s-%s-app-%s", local.projectPrefix, each.key, data.tfe_outputs.root.values.f5xcVirtualSite)
  namespace   = var.namespace
  description = format("HTTP service LB for %s (%s-%s)", each.key, local.projectPrefix, local.buildSuffix)
  labels = merge(local.volterra_common_labels, {
    bu = each.key
  })
  annotations                     = local.volterra_common_annotations
  no_challenge                    = true
  random                          = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true
  domains                         = [format("%sapp.%s", each.key, var.domain_name)]
  http {
    dns_volterra_managed = false
  }
  advertise_custom {
    advertise_where {
      use_default_port = true
      virtual_site {
        network = "SITE_NETWORK_INSIDE"
        virtual_site {
          name      = data.tfe_outputs.root.values.f5xcVirtualSite
          namespace = var.namespace
          tenant    = var.xc_tenant
        }
      }
    }
  }
  default_route_pools {
    pool {
      name      = volterra_origin_pool.inside[each.key].name
      namespace = volterra_origin_pool.inside[each.key].namespace
      tenant    = var.xc_tenant
    }
  }
}
*/