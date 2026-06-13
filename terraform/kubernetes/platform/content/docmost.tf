# ---------------------------------------------------------------------------
# Docmost — wiki / docs, served at docmost.noizu.com. Shared Postgres + Valkey
# (full DSNs in Infisical); local file storage on a PVC. SMTP via SendGrid.
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "docmost_data" {
  metadata {
    name      = "docmost-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "docmost" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.docmost_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "docmost" {
  metadata {
    name      = "docmost"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "docmost" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "docmost" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "docmost" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        security_context {
          fs_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 1000:1000 /app/data/storage"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/app/data/storage"
          }
        }
        container {
          name  = "docmost"
          image = var.docmost_image
          port {
            container_port = 3000
            name           = "http"
          }
          env {
            name  = "APP_URL"
            value = "https://${var.docmost_domain}"
          }
          env {
            name  = "FILE_STORAGE"
            value = "local"
          }
          env {
            name  = "FILES_LIMIT"
            value = "52428800"
          }
          env {
            name  = "MAIL_DRIVER"
            value = "smtp"
          }
          env {
            name  = "SMTP_SECURE"
            value = "true"
          }
          # Required connection + app secrets (full DSNs from Infisical).
          dynamic "env" {
            for_each = {
              DATABASE_URL = "DOCMOST_DATABASE_URL"
              APP_SECRET   = "DOCMOST_JWT_SECRET"
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
          # Optional secrets (Redis cache + SMTP).
          dynamic "env" {
            for_each = {
              REDIS_URL         = "DOCMOST_REDIS_URL"
              SMTP_HOST         = "SMTP_HOST"
              SMTP_PORT         = "SMTP_PORT"
              SMTP_USERNAME     = "SMTP_USER"
              SMTP_PASSWORD     = "SMTP_PASSWORD"
              MAIL_FROM_ADDRESS = "SMTP_FROM"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name     = var.managed_secret_name
                  key      = env.value
                  optional = true
                }
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/app/data/storage"
          }
          resources {
            requests = { cpu = "200m", memory = "256Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 20
          }
          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.docmost_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.infisical_app_secrets,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_service_v1" "docmost" {
  metadata {
    name      = "docmost"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "docmost" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "docmost" }
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "docmost" {
  metadata {
    name      = "docmost-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "docmost" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.docmost_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.docmost_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.docmost.metadata[0].name
              port { number = 3000 }
            }
          }
        }
      }
    }
  }
}
