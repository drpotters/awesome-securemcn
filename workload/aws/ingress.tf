resource "kubernetes_ingress_v1" "app-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "app-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      // host = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
      host = var.app_domain
      http {
        path {
          path = "/"
          backend {
            service {
                name = kubernetes_service.main.metadata[0].name
                port {
                    number = 80
                }
            }
          }
        }
        path {
          path = "/files"
          backend {
            service {
                name = kubernetes_service.backend.metadata[0].name
                port {
                    number = 80
                }
            }
          }
        }
      }
    }
    rule {
      host = "backend.demo.internal"
      http {
        path {
          path = "/files"
          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        /* path {
          path = "/api"
          backend {
            service {
                // name = kubernetes_service.app_2.metadata.0.name
                name = "app2"
                port {
                    number = 80
                }
            }
          }
        }
        path {
          path = "/app3"
          backend {
            service {
                // name = kubernetes_service.app_3.metadata.0.name
                name = "refer-a-friend"
                port {
                    number = 80
                }
            }
          }
        } */
      }
    }
  }
  depends_on = [
    kubernetes_deployment.backend,
    kubernetes_service.backend,
    kubernetes_deployment.main,
    kubernetes_service.main
  ]
}