# =============================================================================
# Roundcube (webmail)
# =============================================================================
locals {
  roundcube_poststart = <<-EOT
    # Wait for start.py to generate nginx config, then patch root path
    for i in $(seq 1 30); do
      if [ -f /etc/nginx/http.d/webmail.conf ]; then
        sed -i 's|root /var/www/;|root /var/www/roundcube/public_html/;|' /etc/nginx/http.d/webmail.conf
        sed -i 's|SCRIPT_NAME /$fastcgi_script_name|SCRIPT_NAME $fastcgi_script_name|' /etc/nginx/http.d/webmail.conf
        nginx -s reload 2>/dev/null || true
        break
      fi
      sleep 1
    done
  EOT
}

resource "kubernetes_deployment_v1" "roundcube" {
  metadata {
    name      = "roundcube"
    namespace = local.ns
    labels    = local.labels["roundcube"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "roundcube" }
    }
    template {
      metadata {
        labels = { app = "roundcube" }
      }
      spec {
        dynamic "image_pull_secrets" {
          for_each = local.image_pull_secrets
          content { name = image_pull_secrets.value }
        }
        container {
          name  = "roundcube"
          image = local.images.roundcube
          port {
            name           = "http"
            container_port = 80
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

          env {
            name  = "WEB_WEBMAIL"
            value = "/"
          }
          env {
            name  = "WEBMAIL"
            value = "roundcube"
          }
          env {
            name  = "IMAP_ADDRESS"
            value = "front"
          }
          env {
            name  = "SMTP_ADDRESS"
            value = "front"
          }
          env {
            name  = "FRONT_ADDRESS"
            value = "front"
          }
          env {
            name  = "ROUNDCUBE_DB_FLAVOR"
            value = "postgresql"
          }
          env {
            name  = "ROUNDCUBE_DB_HOST"
            value = "postgresql"
          }
          env {
            name  = "ROUNDCUBE_DB_PORT"
            value = "5432"
          }
          env {
            name  = "ROUNDCUBE_DB_NAME"
            value = "roundcube"
          }
          env {
            name = "ROUNDCUBE_DB_USER"
            value_from {
              secret_key_ref {
                name = local.app_secret_name
                key  = "ROUNDCUBE_DB_USER"
              }
            }
          }
          env {
            name = "ROUNDCUBE_DB_PW"
            value_from {
              secret_key_ref {
                name = local.app_secret_name
                key  = "ROUNDCUBE_DB_PASSWORD"
              }
            }
          }
          env {
            name  = "MESSAGE_SIZE_LIMIT"
            value = var.message_size_limit
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "1000m", memory = "2Gi" }
          }

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", local.roundcube_poststart]
              }
            }
          }

          readiness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 5
          }
          liveness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 60
            period_seconds        = 30
            failure_threshold     = 5
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

resource "kubernetes_service_v1" "roundcube" {
  metadata {
    name      = "roundcube"
    namespace = local.ns
    labels    = local.labels["roundcube"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "roundcube" }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
  }
}
