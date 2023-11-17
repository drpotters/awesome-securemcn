# Create XC LB config

resource "volterra_origin_pool" "aws-op" {
  name                   = format("%s-xcop-aws-%s", local.project_prefix, local.build_suffix)
  namespace              = var.namespace
  description            = format("Origin pool pointing to origin server %s", local.aws_origin_server)
  dynamic "origin_servers" {
    for_each = local.dns_origin_pool ? [1] : []
    content {
      /* k8s_service {
        service_name = local.service_name
        outside_network = true
        service_selector {
          expressions = ["k8s-svc=arcadia-ingress"]
        }
        site_locator {
          site {
            namespace = "system"
            name = data.tfe_outputs.aws.values.site_name
          }
        }
      } */

      private_ip {
        outside_network = true
        ip = local.aws_service_endpoint_ip
        site_locator {
          site {
            namespace = "system"
            name = data.tfe_outputs.aws.values.site_name
          }
        }  
      }
    }
  }
  /* dynamic "origin_servers" {
    for_each = local.dns_origin_pool ? [] : [1]
    content {
      public_ip {
        ip = local.origin_server
      } 
    }
  } */
  no_tls = true
  port = local.aws_origin_port
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

}

resource "volterra_origin_pool" "azure-op" {
  name                   = format("%s-xcop-azure-%s", local.project_prefix, local.build_suffix)
  namespace              = var.namespace
  description            = format("Origin pool pointing to origin server %s", local.aws_origin_server)
  dynamic "origin_servers" {
    for_each = local.dns_origin_pool ? [1] : []
    content {
      /* k8s_service {
        service_name = local.service_name
        outside_network = true
        service_selector {
          expressions = ["k8s-svc=arcadia-ingress"]
        }
        site_locator {
          site {
            namespace = "system"
            name = data.tfe_outputs.aws.values.site_name
          }
        }
      } */

      private_ip {
        outside_network = true
        ip = local.azure_service_endpoint_ip
        site_locator {
          site {
            namespace = "system"
            name = data.tfe_outputs.azure.values.site_name
          }
        }  
      }
    }
  }
  /* dynamic "origin_servers" {
    for_each = local.dns_origin_pool ? [] : [1]
    content {
      public_ip {
        ip = local.origin_server
      } 
    }
  } */
  no_tls = true
  port = local.aks_origin_port
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}

resource "volterra_app_type" "app-type" {
  count = length(var.xc_app_type) != 0 ? 1 : 0
  name = format("%s-app-type-%s", local.project_prefix, local.build_suffix)
  namespace = "shared"
  features {  
        type = "USER_BEHAVIOR_ANALYSIS" 
  }
  business_logic_markup_setting {
      enable = true
    }
}

resource "volterra_http_loadbalancer" "lb_https" {
  name      = format("%s-xclb-%s", local.project_prefix, local.build_suffix)
  namespace = var.namespace
  labels = {
      "ves.io/app_type" = length(var.xc_app_type) != 0 ? volterra_app_type.app-type[0].name : null
  }
  description = format("HTTPS loadbalancer object for %s origin server", local.project_prefix)  
  domains = [var.app_domain]
  advertise_on_public_default_vip = true
  default_route_pools {
      pool {
        name = volterra_origin_pool.aws-op.name
        namespace = var.namespace
      }
      weight = 1
    }
  routes {
    simple_route {
      http_method = "ANY"
      path {
        prefix = "/api"
      }
      origin_pools {
        pool {
          name= volterra_origin_pool.azure-op.name
          namespace = var.namespace
        }
        weight = 1
      }
    }
  }
  https_auto_cert {
    add_hsts = false
    http_redirect = true
    no_mtls = true
    enable_path_normalize = true
    tls_config {
        default_security = true
      }
  }
  /* app_firewall {
    name = volterra_app_firewall.waap-tf.name
    namespace = var.namespace
  } */
  // disable_waf                     = false
  disable_waf                     = true
  round_robin                     = true
  service_policies_from_namespace = true
  multi_lb_app = var.xc_multi_lb ? true : false
  user_id_client_ip = true
  source_ip_stickiness = true

#API Protection Configuration

  dynamic "enable_api_discovery" {
    for_each = var.xc_api_disc ? [1] : []
    content {
      enable_learn_from_redirect_traffic = true
    } 
  }

  dynamic "api_definition" {
    for_each = var.xc_api_pro ? [1] : []
    content {
      name = volterra_api_definition.api-def[0].name
      namespace = volterra_api_definition.api-def[0].namespace
      tenant = var.xc_tenant
    }
  }

  dynamic "api_protection_rules" {
    for_each = var.xc_api_pro ? [1] : []
    content {
      api_groups_rules {
        metadata {
          name = format("%s-apip-deny-rule-%s", local.project_prefix, local.build_suffix)
        }
        action {
          deny = true
        }
        base_path = "/api"
        api_group = join("-",["ves-io-api-def", volterra_api_definition.api-def[0].name, "all-operations"])
      }
      api_groups_rules {
        metadata {
          name = format("%s-apip-allow-rule-%s", local.project_prefix, local.build_suffix)
        }
        action {
          deny = false
        }
        base_path = "/"
      }
    }
  }

#BOT Configuration
  dynamic "bot_defense" {
    for_each = var.xc_bot_def ? [1] : []
    content {
      policy {
        disable_js_insert = false
        js_insert_all_pages {
          javascript_location = "AFTER_HEAD"
        }
        disable_mobile_sdk = true
        js_download_path = "/common.js"
        protected_app_endpoints {
          metadata {
            name = format("%s-bot-rule-%s", local.project_prefix, local.build_suffix)
          }
          http_methods = ["METHOD_POST", "METHOD_PUT"]
          mitigation {
            block {
              body = "string:///WW91ciByZXF1ZXN0IHdhcyBCTE9DS0VEID4uPAo="
            }
          }
          path {
            path = "/trading/login.php"
          }
          flow_label {
            authentication {
              login {
                transaction_result {
                  failure_conditions {
                    status = "401"
                  }
                }
              }
            }
          }
        }
      }
      regional_endpoint = "US"
      timeout = 1000
    }
  }

#DDoS Configuration
  dynamic "enable_ddos_detection" {
    for_each = var.xc_ddos_def ? [1] : []
    content {
      enable_auto_mitigation = true
    }
  }
  dynamic "ddos_mitigation_rules" {
    for_each = var.xc_ddos_def ? [1] : []
    content {
      metadata {
        name = format("%s-ddos-rule-%s", local.project_prefix, local.build_suffix)
      }
      block = true
      ddos_client_source {
        country_list = [ "COUNTRY_KP"]
      }
    }
  }
  
#Common Security Controls

  disable_rate_limit              = true
  enable_malicious_user_detection = var.xc_mud ? true : null
  no_challenge = contains(var.xc_app_type, "mud") || var.xc_mud ? false : true

  dynamic "policy_based_challenge" {
    for_each = var.xc_mud ? [1] : []
    content {
      default_js_challenge_parameters = true
      default_captcha_challenge_parameters = true
      default_mitigation_settings = true
      no_challenge = true
      rule_list {}
    }
  }
  dynamic "policy_based_challenge" {
    for_each = contains(var.xc_app_type, "mud") && var.xc_multi_lb ? [1] : []
    content {
      malicious_user_mitigation {
        namespace = volterra_malicious_user_mitigation.mud-mitigation[0].namespace
        name = volterra_malicious_user_mitigation.mud-mitigation[0].name
      } 
    }
  }
}


