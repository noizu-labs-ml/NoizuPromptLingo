# =============================================================================
# Dovecot (IMAP/POP3)
# =============================================================================
locals {
  dovecot_ports = {
    imap  = 143
    imaps = 993
    pop3  = 110
    pop3s = 995
    sieve = 4190
    lmtp  = 2525
  }
}

resource "kubernetes_deployment_v1" "dovecot" {
  metadata {
    name      = "dovecot"
    namespace = local.ns
    labels    = local.labels["dovecot"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "dovecot" }
    }
    template {
      metadata {
        labels = { app = "dovecot" }
      }
      spec {
        container {
          name  = "dovecot"
          image = local.images.dovecot

          dynamic "port" {
            for_each = local.dovecot_ports
            content {
              name           = port.key
              container_port = port.value
            }
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

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          volume_mount {
            name       = "mail-data"
            mount_path = "/mail"
          }

          readiness_probe {
            tcp_socket { port = 143 }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          liveness_probe {
            tcp_socket { port = 143 }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }

        volume {
          name = "mail-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.mail.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "dovecot" {
  metadata {
    name      = "dovecot"
    namespace = local.ns
    labels    = local.labels["dovecot"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "dovecot" }

    dynamic "port" {
      for_each = local.dovecot_ports
      content {
        name        = port.key
        port        = port.value
        target_port = port.value
      }
    }
  }
}
