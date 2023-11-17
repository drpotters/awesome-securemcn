resource "kubernetes_service_account" "f5xc-sd-sa" {
    provider = kubernetes.eks

    metadata {
        name = "${var.f5xc-sd-sa}"
    }
}

resource "kubernetes_secret_v1" "f5xc-sd-sa-secret" {
  provider = kubernetes.eks

  metadata {
    annotations = {
        "kubernetes.io/service-account.name" = "${var.f5xc-sd-sa}"
    }
    name = "${var.f5xc-sd-sa}-token"
  }

  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
  depends_on = [ kubernetes_service_account.f5xc-sd-sa ]
}

resource "kubernetes_cluster_role_v1" "f5xc-sd" {
    provider = kubernetes.eks

    metadata {
        name = "f5xc-sd"
    }

    rule {
        api_groups = [""]
        resources = ["endpoints", "nodes", "nodes/proxy", "namespaces", "pods", "services"]
        verbs = ["get", "list", "watch"]
    }
}
resource "kubernetes_cluster_role_binding_v1" "f5xc-sd-sa-binding" {
    provider = kubernetes.eks
    
    metadata {
        name = "f5xc-sd-sa-binding"
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
      kind = "ServiceAccount"
      name = "${var.f5xc-sd-sa}"
    }
}

resource "volterra_discovery" "f5xc-sd" {
    name = format("%s-%s-sd-aws-eks", var.projectPrefix, local.build_suffix)
    namespace = "system"
    labels = {
        "k8s-svc" = "arcadia-ingress"
    }
    no_cluster_id = true

    discovery_k8s {
        access_info {
            kubeconfig_url {
                clear_secret_info {
                  url = format("string:///%s", base64encode(local.kubeconfig_data))
                }
                secret_encoding_type = "base64"
                /* blindfold_secret_info {
                  location = format("string:///%s", base64encode(local.kubeconfig_data))
                } */
            }
        }
        publish_info {
            publish {
                namespace = var.namespace
            }
        }
    }
    where {
        site {
            network_type = "VIRTUAL_NETWORK_SITE_LOCAL"
            ref {
                // kind = "site"
                namespace = "system"
                name = data.tfe_outputs.aws.values.site_name
            }
        }
        
    }
}