resource "kubernetes_ingress_v1" "app3-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "app3-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = { "kubernetes.io/ingress.class" = "gce-internal" }
  }
  spec {
    default_backend {
      // host = try(data.tfe_outputs.nap.values.external_name, data.tfe_outputs.nic.values.external_name)
      service {
        name = kubernetes_service.app3.metadata[0].name
          port {
            number = kubernetes_service.app3.spec[0].port[0].port
          }
      }
    }
  }

  depends_on = [ kubernetes_deployment.app3, kubernetes_service.app3 ]
}

/* resource "google_compute_region_network_firewall_policy_rule" "proxy-subnet" {
  rule_name = "ilb-fw-allow-internal"
  description = "All all from the ILB proxy-subnet to backends"
  direction = "INGRESS"
  disabled = false
  firewall_policy = data.google_compute_network.lb-net.id
  source_ranges = [ data.google_compute_subnetwork.lb-proxy-subnet.ip_cidr_range ]

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

}

/* resource "google_compute_firewall" "proxy-subnet" {
  name = "ilb-fw-allow-internal"
  description = "All all from the ILB proxy-subnet to backends"
  direction = "INGRESS"
  disabled = false
  network = data.google_compute_network.lb-net.id
  source_ranges = [ data.google_compute_subnetwork.lb-proxy-subnet.ip_cidr_range ]

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

}
/* resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "${local.project_prefix}-${local.buildSuffix}-lb-neg"
  network               = data.google_compute_network.lb-net.id
  subnetwork            = data.google_compute_subnetwork.lb-proxy-subnet.id
  project               = var.gcpProjectId
  region                = var.gcpRegion
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
} */