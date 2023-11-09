resource "kubernetes_service" "main" {
  metadata {
    name      = "main"
    namespace = kubernetes_namespace.app.metadata.0.name

    labels = {
      app     = "main"
      service = "main"
    }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
    selector = {
      app = "main"
    }
    type = "ClusterIP"
  }
}
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata.0.name

    labels = {
      app     = "backend"
      service = "backend"
    }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
    selector = {
      app = "backend"
    }
    type = "ClusterIP"
  }
}