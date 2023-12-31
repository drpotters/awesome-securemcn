# F5 XC Enhanced Firewall Policy allows traffic ingress with specific AWS specific tag "prefix" with value "my-mcn-demo"
# Also allow well known CIDR blocks. This will eventually be less favorable by additional provider tagging support.

resource "volterra_enhanced_firewall_policy" "mcn-nc-efp" {
    name = "${var.projectPrefix}-${local.buildSuffix}-enh-fw-pol"
    namespace = "system"
    disable = false

        rule_list {
            rules {
                metadata {
                    name = "internet-to-aws"
                    disable = false
                }
                allow = true
                advanced_action {
                    action = "LOG"
                }
                all_sources = true
                destination_label_selector {
                  expressions = [
                    "aws.ves.io/prefix in (${var.projectPrefix}), aws.ves.io/owner in (${var.resourceOwner})"
                  ]
                }
                applications {
                    applications = [
                        "APPLICATION_HTTP",
                        "APPLICATION_HTTPS"
                    ]
                }
            }
            rules {
                metadata {
                    name = "internet-to-azure"
                    disable = false
                }
                allow = true
                advanced_action {
                    action = "LOG"
                }
                all_sources = true
                destination_prefix_list {
                  prefixes = [
                    "${var.azure_cidr[0].vnet[0].vnetCidr}"
                  ]
                }
                applications {
                    applications = [
                        "APPLICATION_HTTP",
                        "APPLICATION_HTTPS"
                    ]
                }
            }            
            rules {
                metadata {
                    name = "allow-${var.projectPrefix}-awsvpc-prefix"
                    disable = false
                }
                allow = true
                advanced_action {
                    action = "LOG"
                }
                source_label_selector {
                    expressions = [
                        "aws.ves.io/prefix in (${var.projectPrefix})"
                    ]
                }
                outside_destinations = true
                all_traffic = true
                label_matcher {
                    keys = []
                }
            }
            rules {
                metadata {
                    name = "allow-trusted-prefixes"
                    disable = false
                }
                allow = true
                advanced_action {
                    action = "LOG"
                }
                source_prefix_list {
                    prefixes = [
                        // "${var.aws_cidr}", // AWS
                        "${var.azure_cidr[0].vnet[0].vnetCidr}", // Azure
                        "${var.gcp_cidr[0].slo}", // GCP CE SLO subnet
                        "${var.gcp_cidr[0].proxysubnet}"  // GCP ingress load balancers and proxy-only (SNAT) subnets
                    ]
                }
                destination_label_selector {
                  expressions = [
                    "aws.ves.io/prefix in (${var.resourceOwner})"
                  ]
                }
                applications {
                    applications = [
                        "APPLICATION_HTTP",
                        "APPLICATION_HTTPS"
                    ]
                }
                label_matcher {
                    keys = []
                }
            }
            rules {
                metadata {
                    name = "deny-all"
                    disable = false
                }
                deny = true
                advanced_action {
                    action = "LOG"
                }
                label_matcher {
                    keys = []
                }
            }
        }
}