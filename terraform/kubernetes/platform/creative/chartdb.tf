# ChartDB — database schema visualizer, served at chartdb.noizu.com. Stateless.
resource "kubernetes_deployment_v1" "chartdb" {
  metadata {
    name      = "chartdb"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "chartdb" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "chartdb" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "chartdb" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "chartdb"
          image = var.chartdb_image
          port {
            container_port = 80
            name           = "http"
          }
          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_ops_pull]
}

resource "kubernetes_service_v1" "chartdb" {
  metadata {
    name      = "chartdb"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "chartdb" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "chartdb" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "chartdb" {
  metadata {
    name        = "chartdb-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "chartdb" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.chartdb_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.chartdb_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.chartdb.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
