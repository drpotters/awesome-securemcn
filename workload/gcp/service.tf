resource "kubernetes_service" "app3" {
  metadata {
    name      = "app3"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "cloud.google.com/neg" = "{\"ingress\": true}"
      }

    labels = {
      app     = "app3"
      service = "app3"
    }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
    selector = {
      app = "app3"
    }
    type = "ClusterIP"
    // external_traffic_policy = "Cluster"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }
}
