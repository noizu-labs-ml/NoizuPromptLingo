# ---------------------------------------------------------------------------
# Ingresses (nginx class), TLS terminated with the Infisical-synced
# cloudflare-tls-synced wildcard cert.
# ---------------------------------------------------------------------------
locals {
  ingress_base_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
    "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
  }
}

resource "kubernetes_ingress_v1" "erpnext" {
  metadata {
    name      = "erpnext-ingress"
    namespace = var.namespace
    annotations = merge(local.ingress_base_annotations, {
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "120"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "120"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.erpnext_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.erpnext_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.release_name}-erpnext"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.erpnext]
}

resource "kubernetes_ingress_v1" "kimai" {
  metadata {
    name      = "kimai-ingress"
    namespace = var.namespace
    annotations = merge(local.ingress_base_annotations, {
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.kimai_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.kimai_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.kimai.metadata[0].name
              port {
                number = 8001
              }
            }
          }
        }
      }
    }
  }
}
