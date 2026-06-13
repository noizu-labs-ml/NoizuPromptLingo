# =============================================================================
# Mailu Admin (user management, Podop, DKIM)
# =============================================================================
resource "kubernetes_deployment_v1" "admin" {
  metadata {
    name      = "admin"
    namespace = local.ns
    labels    = local.labels["admin"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "admin" }
    }
    template {
      metadata {
        labels = { app = "admin" }
      }
      spec {
        dynamic "image_pull_secrets" {
          for_each = local.image_pull_secrets
          content { name = image_pull_secrets.value }
        }
        container {
          name  = "admin"
          image = local.images.admin
          port {
            name           = "http"
            container_port = 8080
          }

          dynamic "env" {
            for_each = local.common_env_values
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.common_env_secrets
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = local.app_secret_name
                  key  = env.value
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.service_env_values
            content {
              name  = env.key
              value = env.value
            }
          }

          env {
            name  = "WEB_ADMIN"
            value = "/"
          }
          env {
            name  = "ADMIN"
            value = "true"
          }
          dynamic "env" {
            for_each = {
              MAILU_DB_USER     = "MAILU_DB_USER"
              MAILU_DB_PASSWORD = "MAILU_DB_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = local.app_secret_name
                  key  = env.value
                }
              }
            }
          }
          env {
            name  = "SQLALCHEMY_DATABASE_URI"
            value = "postgresql://$(MAILU_DB_USER):$(MAILU_DB_PASSWORD)@postgresql:5432/mailu"
          }
          env {
            name  = "INITIAL_ADMIN_ACCOUNT"
            value = var.postmaster
          }
          env {
            name  = "INITIAL_ADMIN_DOMAIN"
            value = var.domain
          }
          env {
            name = "INITIAL_ADMIN_PW"
            value_from {
              secret_key_ref {
                name = local.app_secret_name
                key  = "MAILU_ADMIN_PASSWORD"
              }
            }
          }
          env {
            name  = "INITIAL_ADMIN_MODE"
            value = "ifmissing"
          }
          env {
            name  = "AUTH_RATELIMIT_IP"
            value = var.auth_ratelimit_ip
          }
          env {
            name  = "MESSAGE_SIZE_LIMIT"
            value = var.message_size_limit
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          volume_mount {
            name       = "dkim"
            mount_path = "/dkim"
          }

          readiness_probe {
            http_get {
              path = "/sso/login"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/sso/login"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }

        volume {
          name = "dkim"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.dkim.metadata[0].name
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

resource "kubernetes_service_v1" "admin" {
  metadata {
    name      = "admin"
    namespace = local.ns
    labels    = local.labels["admin"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "admin" }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}
