# =============================================================================
# Postfix (SMTP — MTA, relays outbound through SendGrid)
# =============================================================================
resource "kubernetes_deployment_v1" "postfix" {
  metadata {
    name      = "postfix"
    namespace = local.ns
    labels    = local.labels["postfix"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "postfix" }
    }
    template {
      metadata {
        labels = { app = "postfix" }
      }
      spec {
        container {
          name  = "postfix"
          image = local.images.postfix
          port {
            name           = "smtp"
            container_port = 25
          }
          port {
            name           = "smtp-internal"
            container_port = 10025
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
            name  = "MESSAGE_SIZE_LIMIT"
            value = var.message_size_limit
          }
          env {
            name  = "REJECT_UNLISTED_RECIPIENT"
            value = "yes"
          }
          env {
            name  = "REJECT_UNLISTED_SENDER"
            value = "yes"
          }
          env {
            name  = "RELAYHOST"
            value = var.postfix_relay_host
          }
          env {
            name  = "RELAYUSER"
            value = var.postfix_relay_username
          }
          env {
            name = "RELAYPASSWORD"
            value_from {
              secret_key_ref {
                name = local.app_secret_name
                key  = "SENDGRID_API_KEY"
              }
            }
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          readiness_probe {
            exec { command = ["sh", "-c", "postfix status"] }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
          liveness_probe {
            exec { command = ["sh", "-c", "postfix status"] }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "postfix" {
  metadata {
    name      = "postfix"
    namespace = local.ns
    labels    = local.labels["postfix"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "postfix" }
    port {
      name        = "smtp"
      port        = 25
      target_port = 25
    }
    port {
      name        = "smtp-internal"
      port        = 10025
      target_port = 10025
    }
  }
}
