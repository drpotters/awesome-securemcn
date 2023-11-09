resource "kubernetes_service" "app2" {
  metadata {
    name      = "app2"
    namespace = kubernetes_namespace.app.metadata.0.name
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = "public"
    }

    labels = {
      app     = "app2"
      service = "app2"
    }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
    selector = {
      app = "app2"
    }
    // type = "ClusterIP"
    type = "LoadBalancer"
  }
}