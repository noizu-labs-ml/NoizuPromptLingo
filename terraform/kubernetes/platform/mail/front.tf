# =============================================================================
# Mailu Front (nginx — mail protocol proxy)
# =============================================================================
locals {
  front_poststart = <<-EOT
    # Patch nginx resolver to include public DNS for external rDNS lookups.
    # Kube-dns alone returns SERVFAIL for in-addr.arpa queries.
    # Wait for nginx PID file (means config.py finished and nginx started).
    for i in $(seq 1 90); do
      if [ -f /var/run/nginx.pid ] && [ -s /var/run/nginx.pid ]; then
        sleep 1
        sed -i 's/resolver \([0-9.]*\) valid/resolver \1 1.1.1.1 valid/g' /etc/nginx/nginx.conf
        nginx -s reload 2>/dev/null || true
        break
      fi
      sleep 1
    done
  EOT

  # Mail protocol ports exposed by both front Services.
  front_mail_ports = {
    smtp       = 25
    smtps      = 465
    submission = 587
    imaps      = 993
    pop3s      = 995
    sieve      = 4190
  }

  # Additional internal proxy ports on the ClusterIP Service only.
  front_proxy_ports = {
    http       = 80
    imap-proxy = 10143
    smtp-proxy = 10025
    lmtp       = 2525
  }
}

resource "kubernetes_deployment_v1" "front" {
  metadata {
    name      = "front"
    namespace = local.ns
    labels    = local.labels["front"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "front" }
    }
    template {
      metadata {
        labels = { app = "front" }
      }
      spec {
        dynamic "image_pull_secrets" {
          for_each = local.image_pull_secrets
          content { name = image_pull_secrets.value }
        }
        container {
          name  = "front"
          image = local.images.front

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", local.front_poststart]
              }
            }
          }

          dynamic "port" {
            for_each = local.front_mail_ports
            content {
              name           = port.key
              container_port = port.value
              protocol       = "TCP"
            }
          }
          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
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

          # Webmail proxied through front so its nginx can inject
          # X-Remote-User / X-Remote-User-Token SSO headers.
          env {
            name  = "WEBMAIL"
            value = "roundcube"
          }
          env {
            name  = "WEB_WEBMAIL"
            value = "/"
          }
          env {
            name  = "WEB_ADMIN"
            value = "none"
          }
          env {
            name  = "WEBROOT_REDIRECT"
            value = "none"
          }
          env {
            name  = "ADMIN"
            value = "true"
          }
          env {
            name  = "TLS_FLAVOR"
            value = "mail"
          }
          env {
            name  = "REAL_IP_HEADER"
            value = "X-Forwarded-For"
          }
          env {
            name  = "REAL_IP_FROM"
            value = var.subnet
          }
          env {
            name  = "MESSAGE_SIZE_LIMIT"
            value = var.message_size_limit
          }
          env {
            name  = "AUTH_RATELIMIT_IP"
            value = var.auth_ratelimit_ip
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          volume_mount {
            name       = "tls-certs"
            mount_path = "/certs/cert.pem"
            sub_path   = "tls.crt"
            read_only  = true
          }
          volume_mount {
            name       = "tls-certs"
            mount_path = "/certs/key.pem"
            sub_path   = "tls.key"
            read_only  = true
          }

          readiness_probe {
            tcp_socket { port = 25 }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          liveness_probe {
            tcp_socket { port = 25 }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }

        volume {
          name = "tls-certs"
          secret {
            # cert-manager is not installed, so the Let's Encrypt secret
            # (le_tls_secret) is never issued. Use the Cloudflare-managed cert
            # (same one the ingress uses), which is provisioned via Infisical.
            secret_name = local.cf_tls_secret
            optional    = false
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

# Internal service — ClusterIP (roundcube proxy + internal routing).
resource "kubernetes_service_v1" "front" {
  metadata {
    name      = "front"
    namespace = local.ns
    labels    = local.labels["front"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "front" }

    dynamic "port" {
      for_each = merge(local.front_mail_ports, local.front_proxy_ports)
      content {
        name        = port.key
        port        = port.value
        target_port = port.value
      }
    }
  }
}

# External service — binds mail ports on the public IP via externalIPs.
# Managed by kube-proxy iptables (survives kube-proxy restarts, unlike hostPort
# CNI rules).
resource "kubernetes_service_v1" "front_external" {
  metadata {
    name      = "front-external"
    namespace = local.ns
    labels    = local.labels["front"]
  }
  spec {
    type         = "ClusterIP"
    external_ips = [var.server_ip]
    selector     = { app = "front" }

    dynamic "port" {
      for_each = local.front_mail_ports
      content {
        name        = port.key
        port        = port.value
        target_port = port.value
      }
    }
  }
}
