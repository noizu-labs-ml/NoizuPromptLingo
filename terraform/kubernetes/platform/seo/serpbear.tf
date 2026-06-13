# ---------------------------------------------------------------------------
# SerpBear — SEO rank tracker, served at serpbear.noizu.com. Self-contained with
# an embedded SQLite database on a persistent volume.
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "serpbear_data" {
  metadata {
    name      = "serpbear-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "serpbear" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.serpbear_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "serpbear" {
  metadata {
    name      = "serpbear"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "serpbear" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "serpbear" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "serpbear" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "serpbear"
          image = var.serpbear_image

          port {
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "NEXT_PUBLIC_APP_URL"
            value = "https://${var.serpbear_domain}"
          }

          dynamic "env" {
            for_each = {
              USER     = "SERPBEAR_USER"
              PASSWORD = "SERPBEAR_PASSWORD"
              SECRET   = "SERPBEAR_SECRET"
              APIKEY   = "SERPBEAR_API_TOKEN"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = var.managed_secret_name
                  key  = env.value
                }
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }

          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.serpbear_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "serpbear" {
  metadata {
    name      = "serpbear"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "serpbear" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "serpbear" }
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "serpbear" {
  metadata {
    name      = "serpbear-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "serpbear" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.serpbear_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.serpbear_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.serpbear.metadata[0].name
              port { number = 3000 }
            }
          }
        }
      }
    }
  }
}
