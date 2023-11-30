resource "helm_release" "prometheus" {
    name = format("%s-pro-%s", local.projectPrefix, local.buildSuffix)
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus"
    #version = "15.10.2"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    values = [file("./charts/prometheus/values.yaml")]
}