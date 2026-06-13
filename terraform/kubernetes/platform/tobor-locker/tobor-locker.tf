# ---------------------------------------------------------------------------
# Tobor Locker — MCP server with API key auth + Next.js dashboard
# ---------------------------------------------------------------------------
# Three-container pod: nginx (port 80) → nextjs (3000) + elixir (4040)
# Postgres via platform shared DB. Liquibase migrations run as an init job.

# --- Deployment: nginx + nextjs + elixir as sidecar containers ---
resource "kubernetes_deployment_v1" "tobor_locker" {
  metadata {
    name      = "tobor-locker"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "tobor-locker" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "tobor-locker" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "tobor-locker" }) }
      spec {
        node_selector      = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }

        container {
          name  = "nginx"
          image = var.nginx_image
          port {
            container_port = 80
            name           = "http"
          }
          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { cpu = "200m", memory = "128Mi" }
          }
          liveness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 5
            period_seconds        = 15
          }
        }

        container {
          name  = "nextjs"
          image = var.nextjs_image
          port { container_port = 3000 }

          env_from {
            secret_ref { name = "tobor-locker-secrets" }
          }

          env {
            name  = "AUTH_TRUST_HOST"
            value = "true"
          }
          env {
            name  = "AUTH_URL"
            value = "https://${var.domain}"
          }
          env {
            name  = "BACKEND_URL"
            value = "http://localhost:4040"
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/api/auth/csrf"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
        }

        container {
          name  = "elixir"
          image = var.elixir_image
          port { container_port = 4040 }

          env_from {
            secret_ref { name = "tobor-locker-secrets" }
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 4040
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 4040
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.infisical_app,
    kubectl_manifest.infisical_ops_pull,
  ]
}

# --- Service ---
resource "kubernetes_service_v1" "tobor_locker" {
  metadata {
    name      = "tobor-locker"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "tobor-locker" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "tobor-locker" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# --- Ingress ---
resource "kubernetes_ingress_v1" "tobor_locker" {
  metadata {
    name        = "tobor-locker-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "tobor-locker" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.tobor_locker.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
