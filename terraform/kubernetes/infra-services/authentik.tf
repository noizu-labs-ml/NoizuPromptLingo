# ---------------------------------------------------------------------------
# Authentik — identity provider (server + worker), served at auth.noizu.com
# (cloudflare-tls-synced) and auth.derobot.is (derobotis-tls).
# ---------------------------------------------------------------------------
# Non-secret config (AUTHENTIK_POSTGRESQL__HOST/NAME/PORT, AUTHENTIK_REDIS__*,
# email host, etc.) lives in the `authentik` sealed secret (envFrom). Credentials
# live in `authentik-secrets`. Both are unsealed by the controller.
#
# NOTE: the live worker also mounts an optional "mermaid" blueprint secret; that
# is omitted here — add it back if/when the blueprint secret is sealed.
locals {
  authentik_host         = "auth.noizu.com"
  authentik_host_derobot = "auth.derobot.is"
  authentik_image        = "ghcr.io/goauthentik/server:2025.6.0"

  # Secret-sourced env shared by server and worker (from authentik-secrets).
  authentik_secret_env = {
    AUTHENTIK_POSTGRESQL__USER     = "AUTHENTIK_DB_USER"
    AUTHENTIK_POSTGRESQL__PASSWORD = "AUTHENTIK_DB_PASSWORD"
    AUTHENTIK_SECRET_KEY           = "AUTHENTIK_SECRET_KEY"
  }

  # infra-valkey ACL user creds (from the init-owned authentik-valkey secret),
  # shared by server and worker.
  authentik_redis_env = {
    AUTHENTIK_REDIS__USERNAME = "VALKEY_USERNAME"
    AUTHENTIK_REDIS__PASSWORD = "VALKEY_PASSWORD"
  }
}

resource "kubernetes_deployment_v1" "authentik_server" {
  metadata {
    name      = "authentik-server"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "server" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "server" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "server" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "server"
          image = local.authentik_image
          args  = ["server"]

          port {
            name           = "http"
            container_port = 9000
          }
          port {
            name           = "https"
            container_port = 9443
          }
          port {
            name           = "metrics"
            container_port = 9300
          }

          env_from {
            secret_ref { name = "authentik" }
          }
          env_from {
            secret_ref { name = "authentik-secrets" }
          }

          dynamic "env" {
            for_each = local.authentik_secret_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "authentik-secrets"
                  key  = env.value
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.authentik_redis_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "authentik-valkey"
                  key  = env.value
                }
              }
            }
          }
          env {
            name = "AUTHENTIK_BOOTSTRAP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "authentik-secrets"
                key  = "AUTHENTIK_BOOTSTRAP_PASSWORD"
              }
            }
          }
          env {
            name = "AUTHENTIK_BOOTSTRAP_EMAIL"
            value_from {
              secret_key_ref {
                name = "authentik-secrets"
                key  = "AUTHENTIK_BOOTSTRAP_EMAIL"
              }
            }
          }
          env {
            name = "AUTHENTIK_EMAIL__PASSWORD"
            value_from {
              secret_key_ref {
                name = "authentik-secrets"
                key  = "SENDGRID_API_KEY"
              }
            }
          }
          env {
            name  = "AUTHENTIK_COOKIE_DOMAIN"
            value = "auth.derobot.is"
          }
          env {
            name  = "AUTHENTIK_LISTEN__HTTP"
            value = "0.0.0.0:9000"
          }
          env {
            name  = "AUTHENTIK_LISTEN__HTTPS"
            value = "0.0.0.0:9443"
          }
          env {
            name  = "AUTHENTIK_LISTEN__METRICS"
            value = "0.0.0.0:9300"
          }

          resources {
            requests = { cpu = "100m", memory = "512Mi" }
            limits   = { cpu = "1", memory = "1Gi" }
          }

          # First boot runs DB migrations before the HTTP server binds; without a
          # startup probe the liveness probe (≈35s) kills the container mid-migration
          # in a crash loop. Give migrations up to ~5min to complete before liveness
          # takes over.
          startup_probe {
            http_get {
              path = "/-/health/live/"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 60
          }
          liveness_probe {
            http_get {
              path = "/-/health/live/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 1
          }
          readiness_probe {
            http_get {
              path = "/-/health/ready/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]
}

resource "kubernetes_deployment_v1" "authentik_worker" {
  metadata {
    name      = "authentik-worker"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "worker" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "worker" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "worker" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "worker"
          image = local.authentik_image
          args  = ["worker"]

          env_from {
            secret_ref { name = "authentik" }
          }
          env_from {
            secret_ref { name = "authentik-secrets" }
          }

          dynamic "env" {
            for_each = local.authentik_secret_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "authentik-secrets"
                  key  = env.value
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.authentik_redis_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "authentik-valkey"
                  key  = env.value
                }
              }
            }
          }

          resources {
            requests = { cpu = "100m", memory = "512Mi" }
            limits   = { cpu = "1", memory = "1Gi" }
          }

          # Worker also waits on first-boot migrations; give it the same grace
          # period before the liveness healthcheck can kill it.
          startup_probe {
            exec { command = ["ak", "healthcheck"] }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 5
            failure_threshold     = 60
          }
          liveness_probe {
            exec { command = ["ak", "healthcheck"] }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 1
          }
          readiness_probe {
            exec { command = ["ak", "healthcheck"] }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]
}

resource "kubernetes_service_v1" "authentik" {
  metadata {
    name      = "authentik-server"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "authentik", "app.kubernetes.io/component" = "server" }
    port {
      name        = "http"
      port        = 80
      target_port = 9000
    }
  }
}

resource "kubernetes_ingress_v1" "authentik" {
  metadata {
    name      = "authentik-server"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "authentik" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"   = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "4"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.authentik_host]
      secret_name = "cloudflare-tls-synced"
    }
    tls {
      hosts       = [local.authentik_host_derobot]
      secret_name = "derobotis-tls"
    }
    dynamic "rule" {
      for_each = toset([local.authentik_host, local.authentik_host_derobot])
      content {
        host = rule.value
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = kubernetes_service_v1.authentik.metadata[0].name
                port { number = 80 }
              }
            }
          }
        }
      }
    }
  }
}
