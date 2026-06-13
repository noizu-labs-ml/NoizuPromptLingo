# ---------------------------------------------------------------------------
# ArgoCD — GitOps CD, served at argocd.noizu.com. Upstream argo-cd chart; Dex is
# disabled (auth via Cloudflare Zero Trust). Deployed into the infra namespace,
# reusing the existing cloudflare-tls-synced wildcard cert. Server runs insecure
# behind the nginx ingress (TLS terminated at the edge).
# ---------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = local.ns
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  timeout = 900
  wait    = false

  values = [yamlencode({
    global = {
      domain = var.argocd_domain
    }

    server = {
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
          "nginx.ingress.kubernetes.io/proxy-body-size"        = "50m"
          "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
          "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
          "nginx.ingress.kubernetes.io/backend-protocol"       = "HTTP"
          "nginx.ingress.kubernetes.io/whitelist-source-range" = local.cloudflare_ip_whitelist
        }
        hostname = var.argocd_domain
        tls      = false
        extraTls = [{
          secretName = "cloudflare-tls-synced"
          hosts      = [var.argocd_domain]
        }]
      }
      resources = {
        requests = { cpu = "100m", memory = "256Mi" }
        limits   = { cpu = "1000m", memory = "1Gi" }
      }
    }

    controller = {
      resources = {
        requests = { cpu = "100m", memory = "256Mi" }
        limits   = { cpu = "1000m", memory = "1Gi" }
      }
    }

    repoServer = {
      resources = {
        requests = { cpu = "50m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }

    redis = {
      resources = {
        requests = { cpu = "50m", memory = "64Mi" }
        limits   = { cpu = "250m", memory = "256Mi" }
      }
    }

    applicationSet = { enabled = false }
    notifications  = { enabled = false }
    dex            = { enabled = false }

    configs = {
      params = {
        "server.insecure" = true
      }
      cm = {
        url = "https://${var.argocd_domain}"
      }
    }
  })]
}
