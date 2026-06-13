# draw.io — diagramming tool, served at drawio.noizu.com. Stateless. Optional
# Google/Microsoft OAuth is disabled (seed DRAWIO_* in /creative and add env if needed).
resource "kubernetes_deployment_v1" "drawio" {
  metadata {
    name      = "drawio"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "drawio" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "drawio" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "drawio" }) }
      spec {
        node_selector = local.node_selector
        container {
          name  = "drawio"
          image = var.drawio_image
          port {
            container_port = 8080
            name           = "http"
          }
          env {
            name  = "DRAWIO_BASE_URL"
            value = "https://${var.drawio_domain}"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "drawio" {
  metadata {
    name      = "drawio"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "drawio" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "drawio" }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "drawio" {
  metadata {
    name        = "drawio-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "drawio" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.drawio_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.drawio_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.drawio.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
