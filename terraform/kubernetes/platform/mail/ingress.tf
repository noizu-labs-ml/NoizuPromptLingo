# =============================================================================
# Ingresses — webmail, admin, and MTA-STS (all Cloudflare-fronted, nginx class).
# =============================================================================
# Annotations reproduce the shared "cloudflare-lib.ingress-annotations" helper:
# ssl-redirect, proxy body size / timeouts, and the Cloudflare source-range
# whitelist. Mail protocols (SMTP/IMAP/POP3) are NOT served via ingress — the
# front container binds them directly via externalIPs.
# =============================================================================
locals {
  # Cloudflare IPv4 + IPv6 ranges (https://www.cloudflare.com/ips/).
  cloudflare_ip_whitelist = "173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/13,104.24.0.0/14,172.64.0.0/13,131.0.72.0/22,2400:cb00::/32,2606:4700::/32,2803:f800::/32,2405:b500::/32,2405:8100::/32,2a06:98c0::/29,2c0f:f248::/32"

  cf_ingress_annotations = { for body_size in ["50m", "10m", "1m"] : body_size => {
    "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
    "nginx.ingress.kubernetes.io/proxy-body-size"        = body_size
    "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
    "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
    "nginx.ingress.kubernetes.io/whitelist-source-range" = local.cloudflare_ip_whitelist
  } }
}

# --- Webmail (webmail.therobotlives.com) -> roundcube ---
resource "kubernetes_ingress_v1" "webmail" {
  metadata {
    name        = "webmail-ingress"
    namespace   = local.ns
    labels      = local.common_labels
    annotations = local.cf_ingress_annotations["50m"]
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.roundcube_domain]
      secret_name = local.cf_tls_secret
    }
    rule {
      host = var.roundcube_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.front.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}

# --- Admin (mail-admin.therobotlives.com) -> admin ---
resource "kubernetes_ingress_v1" "admin" {
  metadata {
    name        = "admin-ingress"
    namespace   = local.ns
    labels      = local.common_labels
    annotations = local.cf_ingress_annotations["10m"]
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.admin_domain]
      secret_name = local.cf_tls_secret
    }
    rule {
      host = var.admin_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.admin.metadata[0].name
              port { number = 8080 }
            }
          }
        }
      }
    }
  }
}

# --- MTA-STS (mta-sts.therobotlives.com) -> mta-sts ---
resource "kubernetes_ingress_v1" "mta_sts" {
  metadata {
    name        = "mta-sts-ingress"
    namespace   = local.ns
    labels      = local.common_labels
    annotations = local.cf_ingress_annotations["1m"]
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.mta_sts_domain]
      secret_name = local.cf_tls_secret
    }
    rule {
      host = var.mta_sts_domain
      http {
        path {
          path      = "/.well-known/mta-sts.txt"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service_v1.mta_sts.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
