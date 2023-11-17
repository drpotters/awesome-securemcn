# AWS
resource "kubernetes_namespace" "eks-app" {
  provider = kubernetes.eks

  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}


resource "kubernetes_secret" "eks-docker-secret" {
  provider = kubernetes.eks

  count = (var.use_private_registry) ? 1 : 0

  metadata {
    name      = "repo-secret"
    namespace = kubernetes_namespace.eks-app.metadata.0.name
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

resource "kubernetes_deployment" "main" {
  provider = kubernetes.eks

  metadata {
    name = "main"
    namespace = kubernetes_namespace.eks-app.metadata.0.name

    labels = {
      app = "main"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "main"
      }
    }
    template {
      metadata {
        labels = {
          app = "main"
        }
      }
      spec {
        container {
          name    = "main"
          image   = "registry.gitlab.com/f5xc-dpotter/arcadia-distributed/main-php-fpm:latest"
          env {
            name  = "SKIP_CHOWN"
            value = "1"
          }
          command = [ "/bin/sh" ]
          // wait 30 seconds for the configmap coredns override to update across the cluster
          args    = [ "-c", "sleep 30; sudo /php-fpm-use-www-data.sh && sudo php-fpm7.2 -nDOd extension=json.so -d extension=curl.so --fpm-config /etc/php/7.2/fpm/pool.d/www.conf; sudo nginx '-g daemon off;'" ]
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
          // image_pull_policy = "IfNotPresent"
          image_pull_policy = "Always"
        }
        image_pull_secrets {
          name  = "repo-secret"
        }
      }
    }
  }
  depends_on = [kubernetes_secret.eks-docker-secret]
}

resource "kubernetes_deployment" "backend" {
  provider = kubernetes.eks

  metadata {
    name = "backend"
    namespace = kubernetes_namespace.eks-app.metadata.0.name

    labels = {
      app = "backend"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "registry.gitlab.com/f5xc-dpotter/arcadia-distributed/backend:latest"
          env {
            name  = "service_name"
            value = "backend"
          }
          command = [ "/bin/sh" ]
          args    = [ "-c", "sudo php-fpm7.2 -nD; sudo nginx '-g daemon off;'" ]
          port {
            container_port = 8080
          }
          image_pull_policy = "IfNotPresent"
        }
        image_pull_secrets {
          name  = "repo-secret"
        }
      }
    }
  }
  depends_on = [ kubernetes_secret.eks-docker-secret ]
}

# Azure
resource "kubernetes_namespace" "aks-app" {
  provider = kubernetes.aks

  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}


resource "kubernetes_secret" "aks-docker-secret" {
  provider = kubernetes.aks

  count = (var.use_private_registry) ? 1 : 0

  metadata {
    name      = "repo-secret"
    namespace = kubernetes_namespace.aks-app.metadata.0.name
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
  provider = kubernetes.aks

  metadata {
    name = "app2"
    namespace = kubernetes_namespace.aks-app.metadata.0.name

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
  depends_on = [kubernetes_secret.aks-docker-secret]
}

# GCP
resource "kubernetes_namespace" "gke-app" {
  provider = kubernetes.gke

  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }

  depends_on = [ kubernetes_cluster_role_binding_v1.f5xc-sa-binding ]
}

resource "kubernetes_cluster_role_v1" "f5xc-sa" {
  provider = kubernetes.gke

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
  provider = kubernetes.gke

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

resource "kubernetes_secret" "gke-docker-secret" {
  provider = kubernetes.gke

  count = (var.use_private_registry) ? 1 : 0

  metadata {
    name      = "repo-secret"
    namespace = kubernetes_namespace.gke-app.metadata.0.name
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
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "app3" {
  provider = kubernetes.gke
  
  metadata {
    name = "app3"
    namespace = kubernetes_namespace.gke-app.metadata[0].name

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
  depends_on = [ kubernetes_secret.gke-docker-secret ]
}