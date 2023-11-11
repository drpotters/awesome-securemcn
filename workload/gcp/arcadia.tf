resource "kubernetes_namespace" "app" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }

  depends_on = [ kubernetes_cluster_role_binding_v1.f5xc-sa-binding ]
}

resource "kubernetes_cluster_role_v1" "f5xc-sa" {
    metadata {
        name = "f5xc-sa"
    }

    rule {
        api_groups = [""]
        resources = ["endpoints", "nodes", "nodes/proxy", "namespaces", "pods", "services"]
        verbs = ["get", "list", "watch"]
    }
}
resource "kubernetes_cluster_role_binding_v1" "f5xc-sa-binding" {
    metadata {
        name = "f5xc-sa-binding"
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
      kind = "ServiceAccount"
      name = data.google_service_account.me.account_id
    }
}

resource "kubernetes_secret" "docker" {
  count = (var.use_private_registry) ? 1 : 0

  metadata {
    name      = "repo-secret"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email" = var.registry_email
          "auth" = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })

    // ".dockerconfigjson" = base64decode("eyJhdXRocyI6eyJyZWdpc3RyeS5naXRsYWIuY29tIjp7InVzZXJuYW1lIjoiZ2l0bGFiK2RlcGxveS10b2tlbi0xMjYwMTY0IiwicGFzc3dvcmQiOiJSZ1NDcmVfVXdBOEI4YWVETWp4USIsImF1dGgiOiJaMmwwYkdGaUsyUmxjR3h2ZVMxMGIydGxiaTB4TWpZd01UWTBPbEpuVTBOeVpWOVZkMEU0UWpoaFpVUk5hbmhSIn19fQ==")
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "app3" {
  metadata {
    name = "app3"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app = "app3"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app3"
      }
    }
    template {
      metadata {
        labels = {
          app = "app3"
        }
      }
      spec {
        container {
          name    = "app3"
          image   = "registry.gitlab.com/f5xc-dpotter/arcadia-distributed/app3:latest"
          env {
            name  = "SKIP_CHOWN"
            value = "1"
          }
          #command = [ "/bin/sh" ]
          #args    = [ "-c", "sudo /php-fpm-use-www-data.sh && sudo php-fpm7.2 -nDOd extension=json.so -d extension=curl.so --fpm-config /etc/php/7.2/fpm/pool.d/www.conf; sudo nginx '-g daemon off;'" ]
          port {
            container_port = 8080
          }
          resources {
            limits = {
              memory = "200Mi"
              // hugepages-1Mi: 100Mi
              // hugepages-2Mi: 100Mi
            }
          }
          image_pull_policy = "IfNotPresent"
        }
        image_pull_secrets {
          name  = "repo-secret"
        }
      }
    }
  }
  depends_on = [kubernetes_secret.docker]
}