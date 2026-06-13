# ---------------------------------------------------------------------------
# Platform-SEO tier namespace. Holds the self-hosted SEO tools (seonaut,
# serpbear). Credentials are managed by Infisical (the operator syncs them from
# /seo + /shared/* into the managed Secrets these workloads consume). Requires
# the infisical operator + universal-auth-credentials (set up by infra-services).
# ---------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "seo" {
  metadata {
    name = var.namespace
  }
}

locals {
  ns = kubernetes_namespace_v1.seo.metadata[0].name

  common_labels = {
    "app.kubernetes.io/part-of"    = "noizu-platform-seo"
    "app.kubernetes.io/managed-by" = "terraform"
  }

  # Cloudflare IP ranges (IPv4 + IPv6) — mirrors shared/cloudflare-lib
  # "cloudflare-lib.ip-whitelist".
  cf_ip_whitelist = "173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/13,104.24.0.0/14,172.64.0.0/13,131.0.72.0/22,2400:cb00::/32,2606:4700::/32,2803:f800::/32,2405:b500::/32,2405:8100::/32,2a06:98c0::/29,2c0f:f248::/32"

  # Standard NGINX/Cloudflare ingress annotations — mirrors the
  # "cloudflare-lib.ingress-annotations" helper.
  cf_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
    "nginx.ingress.kubernetes.io/whitelist-source-range" = local.cf_ip_whitelist
  }
}
