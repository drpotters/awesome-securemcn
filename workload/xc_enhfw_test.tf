# F5 XC Enhanced Firewall Policy allows traffic ingress with specific AWS specific tag "prefix" with value "my-mcn-demo"
# Also allow well known CIDR blocks. This will eventually be less favorable by additional provider tagging support.

resource "volterra_enhanced_firewall_policy" "mcn-nc-efp" {
    name = "arcadia-network-connect"
    namespace = "system"
    disable = false

        rule_list {
            rules {
                metadata {
                    name = "allow-${var.projectPrefix}-awsvpc-prefix"
                    disable = false
                }
                advanced_action {
                    action = "NOLOG"
                }
                source_label_selector {
                    expressions = [
                        "aws.ves.io/prefix in (${var.projectPrefix})"
                    ]
                }
                label_matcher {
                    keys = []
                }
            }
            rules {
                metadata {
                    name = "allow-trusted-prefixes"
                    disable = false
                }
                advanced_action {
                    action = "NOLOG"
                }
                source_prefix_list {
                    prefixes = [
                        "10.0.0.0/8", // AWS
                        "10.1.0.0/8", // Azure
                        "10.2.0.0/8", // GCP
                        "10.3.0.0/8"  // GCP other workloads, maybe
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
                advanced_action {
                    action = "NOLOG"
                }
                label_matcher {
                    keys = []
                }
            }
        }
}