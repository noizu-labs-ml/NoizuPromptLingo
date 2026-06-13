# ---------------------------------------------------------------------------
# Infisical — secrets manager, served at infisical.noizu.com.
# ---------------------------------------------------------------------------
# Uses the SHARED data tier (infra module): Postgres on infra-timescaledb and
# Redis on infra-valkey — no dedicated DBs. The infisical Postgres role/DB is
# provisioned by infra (postgres.tf local.pg_app_dbs + files/postgres/initdb.d/)
# and its password lives in the sealed postgres-secrets. The infisical Valkey ACL
# user is owned by init (valkey-creds.tf); its password reaches us via init's
# remote state, from which we build REDIS_URL here.
#
# Secrets consumed by the app:
#   infisical-core-secrets (sealed; seal-secrets.sh) — ENCRYPTION_KEY,
#     AUTH_SECRET, DB_CONNECTION_URI (postgres URL w/ the shared-DB password),
#     SMTP_* (SendGrid/SMTP configuration).
#   infisical-redis        (this file)               — REDIS_URL (shared valkey).
locals {
  infisical_image = "infisical/infisical:v0.154.5"
  infisical_host  = "infisical.noizu.com"
  infisical_port  = 8080

  # Shared-valkey ACL password for the infisical user (init is source of truth).
  infisical_valkey_password = lookup(local.shared_valkey_users, "infisical", "")
  infisical_redis_url       = "redis://infisical:${local.infisical_valkey_password}@infra-valkey:6379"
}

# --- Redis URL (shared infra-valkey) ---------------------------------------
# Built in Terraform because the valkey password is owned by init (remote state),
# not reachable by the standalone seal script. DB_CONNECTION_URI, by contrast, is
# sealed by seal-secrets.sh (the shared-DB password is in infra's values.env).
resource "kubernetes_secret_v1" "infisical_redis" {
  metadata {
    name      = "infisical-redis"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "infisical" })
  }
  type = "Opaque"
  data = {
    REDIS_URL = local.infisical_redis_url
  }
}

# --- Infisical app ---------------------------------------------------------
resource "kubernetes_deployment_v1" "infisical" {
  metadata {
    name      = "infisical"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "infisical" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "infisical" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "infisical" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "infisical"
          image = local.infisical_image

          port {
            name           = "http"
            container_port = local.infisical_port
          }

          # App keys + shared-Postgres connection (sealed).
          dynamic "env" {
            for_each = {
              ENCRYPTION_KEY    = "ENCRYPTION_KEY"
              AUTH_SECRET       = "AUTH_SECRET"
              DB_CONNECTION_URI = "DB_CONNECTION_URI"
              SMTP_HOST         = "SMTP_HOST"
              SMTP_USERNAME     = "SMTP_USERNAME"
              SMTP_PASSWORD     = "SMTP_PASSWORD"
              SMTP_PORT         = "SMTP_PORT"
              SMTP_FROM_ADDRESS = "SMTP_FROM_ADDRESS"
              SMTP_FROM_NAME    = "SMTP_FROM_NAME"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "infisical-core-secrets"
                  key  = env.value
                }
              }
            }
          }
          # Shared-Valkey connection (materialised above).
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.infisical_redis.metadata[0].name
                key  = "REDIS_URL"
              }
            }
          }
          env {
            name  = "SITE_URL"
            value = "https://${local.infisical_host}"
          }
          env {
            name  = "NODE_ENV"
            value = "production"
          }
          env {
            name  = "PORT"
            value = tostring(local.infisical_port)
          }
          env {
            name  = "AUTO_MIGRATION"
            value = "true"
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { memory = "2Gi" }
          }

          liveness_probe {
            http_get {
              path = "/api/status"
              port = local.infisical_port
            }
            initial_delay_seconds = 90
            period_seconds        = 15
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/api/status"
              port = local.infisical_port
            }
            initial_delay_seconds = 15
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.sealed,
    kubernetes_secret_v1.infisical_redis,
  ]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "infisical" {
  metadata {
    name      = "infisical"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "infisical" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "infisical" }
    port {
      name        = "http"
      port        = 80
      target_port = local.infisical_port
    }
  }
}

resource "kubernetes_ingress_v1" "infisical" {
  metadata {
    name      = "infisical"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "infisical" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.infisical_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.infisical_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.infisical.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
