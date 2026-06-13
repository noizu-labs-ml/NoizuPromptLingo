# ---------------------------------------------------------------------------
# Cockpit — proxy to the host-local Cockpit UI, served at cockpit.noizu.com.
# ---------------------------------------------------------------------------
# Cockpit runs on the base server itself (not in-cluster). This is a
# selector-less Service + manual Endpoints pointing at the host IP, fronted by
# an ingress. TLS uses the sealed cloudflare-tls-synced secret (the chart's
# infisical-tls-sync is unnecessary here).
locals {
  cockpit_host = "cockpit.noizu.com"

  # Restrict ingress to Cloudflare's published ranges (from cloudflare-lib).
  cloudflare_ip_whitelist = join(",", [
    "173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22",
    "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20",
    "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13",
    "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22",
    "2400:cb00::/32", "2606:4700::/32", "2803:f800::/32", "2405:b500::/32",
    "2405:8100::/32", "2a06:98c0::/29", "2c0f:f248::/32",
  ])
}

variable "cockpit_internal_ip" {
  description = "Host IP where Cockpit listens (base server)."
  type        = string
  default     = "10.1.0.1"
}

variable "cockpit_port" {
  description = "Cockpit port on the host."
  type        = number
  default     = 9090
}

resource "kubernetes_service_v1" "cockpit" {
  metadata {
    name      = "cockpit-proxy"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "cockpit", "app.kubernetes.io/component" = "proxy" })
  }
  spec {
    # No selector — endpoints are managed manually below.
    port {
      name        = "http"
      port        = var.cockpit_port
      target_port = var.cockpit_port
    }
  }
}

resource "kubernetes_endpoints_v1" "cockpit" {
  metadata {
    name      = "cockpit-proxy" # must match the Service name
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "cockpit", "app.kubernetes.io/component" = "proxy" })
  }
  subset {
    address {
      ip = var.cockpit_internal_ip
    }
    port {
      name = "http"
      port = var.cockpit_port
    }
  }
}

resource "kubernetes_ingress_v1" "cockpit" {
  metadata {
    name      = "cockpit-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "cockpit", "app.kubernetes.io/component" = "proxy" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "3600"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = local.cloudflare_ip_whitelist
      "nginx.ingress.kubernetes.io/backend-protocol"       = "HTTP"
      "nginx.ingress.kubernetes.io/proxy-http-version"     = "1.1"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.cockpit_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.cockpit_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.cockpit.metadata[0].name
              port { number = var.cockpit_port }
            }
          }
        }
      }
    }
  }
}
