resource "kubernetes_namespace" "app" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
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
          // "email" = var.registry_email
          "auth" = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "app2" {
  metadata {
    name = "app2"
    namespace = kubernetes_namespace.app.metadata.0.name

    labels = {
      app = "app2"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app2"
      }
    }
    template {
      metadata {
        labels = {
          app = "app2"
        }
      }
      spec {
        container {
          name    = "api"
          image   = "registry.gitlab.com/f5xc-dpotter/arcadia-distributed/app2-php-fpm:latest"
          env {
            name  = "SKIP_CHOWN"
            value = "1"
          }
          command = [ "/bin/sh" ]
          args    = [ "-c", "sudo /php-fpm-use-www-data.sh && sudo php-fpm7.2 -nDOd extension=json.so -d extension=curl.so --fpm-config /etc/php/7.2/fpm/pool.d/www.conf; sudo nginx '-g daemon off;'" ]
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