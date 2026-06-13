# ---------------------------------------------------------------------------
# Arize Phoenix — LLM eval/observability, served at eval.noizu.com.
# ---------------------------------------------------------------------------
# Uses the shared Postgres (DB URL in phoenix-secrets). OTLP gRPC on 4317.
locals {
  phoenix_host = "eval.noizu.com"
}

resource "kubernetes_persistent_volume_claim_v1" "phoenix" {
  metadata {
    name      = "phoenix-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "phoenix" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "10Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "phoenix" {
  metadata {
    name      = "phoenix"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "phoenix" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "phoenix" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "phoenix" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 1000:1000 /data"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "phoenix-data"
            mount_path = "/data"
          }
        }
        init_container {
          name    = "wait-for-postgres"
          image   = "busybox:1.36"
          command = ["sh", "-c", "until nc -z infra-timescaledb.${local.ns}.svc.cluster.local 5432; do echo 'Waiting for PostgreSQL...'; sleep 5; done"]
        }
        container {
          name  = "phoenix"
          image = "arizephoenix/phoenix:12.18.0"

          port {
            name           = "http"
            container_port = 6006
          }
          port {
            name           = "otlp-grpc"
            container_port = 4317
          }

          env {
            name = "PHOENIX_SQL_DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "phoenix-secrets"
                key  = "PHOENIX_DATABASE_URL"
              }
            }
          }
          env {
            name  = "PHOENIX_WORKING_DIR"
            value = "/data"
          }
          env {
            name  = "PHOENIX_PORT"
            value = "6006"
          }
          env {
            name  = "PHOENIX_HOST"
            value = "0.0.0.0"
          }
          env {
            name  = "PHOENIX_ENABLE_AUTH"
            value = "True"
          }
          env {
            name  = "PHOENIX_ROOT_URL"
            value = "https://${local.phoenix_host}"
          }
          env {
            name  = "PHOENIX_USE_SECURE_COOKIES"
            value = "True"
          }
          env {
            name  = "PHOENIX_CSRF_TRUSTED_ORIGINS"
            value = "https://${local.phoenix_host},https://accounts.google.com"
          }
          env {
            name  = "PHOENIX_OAUTH2_GOOGLE_OIDC_CONFIG_URL"
            value = "https://accounts.google.com/.well-known/openid-configuration"
          }

          dynamic "env" {
            for_each = {
              PHOENIX_SECRET                      = "PHOENIX_SECRET"
              PHOENIX_ADMIN_SECRET                = "PHOENIX_ADMIN_SECRET"
              PHOENIX_OAUTH2_GOOGLE_CLIENT_ID     = "PHOENIX_OAUTH2_GOOGLE_CLIENT_ID"
              PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET = "PHOENIX_OAUTH2_GOOGLE_CLIENT_SECRET"
              PHOENIX_SMTP_HOSTNAME               = "PHOENIX_SMTP_HOSTNAME"
              PHOENIX_SMTP_USERNAME               = "PHOENIX_SMTP_USERNAME"
              PHOENIX_SMTP_PASSWORD               = "PHOENIX_SMTP_PASSWORD"
              PHOENIX_SMTP_MAIL_FROM              = "PHOENIX_SMTP_MAIL_FROM"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "phoenix-secrets"
                  key  = env.value
                }
              }
            }
          }

          volume_mount {
            name       = "phoenix-data"
            mount_path = "/data"
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "1", memory = "2Gi" }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 6006
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 6006
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "phoenix-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.phoenix.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]
}

resource "kubernetes_service_v1" "phoenix" {
  metadata {
    name      = "phoenix"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "phoenix" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "phoenix" }
    port {
      name        = "http"
      port        = 6006
      target_port = 6006
    }
    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
    }
  }
}

resource "kubernetes_ingress_v1" "phoenix" {
  metadata {
    name      = "phoenix-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "phoenix" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.phoenix_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.phoenix_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.phoenix.metadata[0].name
              port { number = 6006 }
            }
          }
        }
      }
    }
  }
}
