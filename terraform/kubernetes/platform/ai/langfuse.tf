# ---------------------------------------------------------------------------
# Langfuse — LLM observability, served at langfuse.noizu.com.
# Hand-translated from local chart templates. DB lives in the shared Postgres
# (connection string comes from langfuse-app-secrets/LANGFUSE_DATABASE_URL).
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "langfuse_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-langfuse-secrets"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = local.infisical_base.resync_interval
      hostAPI        = local.infisical_base.host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = local.infisical_base.credentials_secret
            secretNamespace = local.infisical_base.credentials_namespace
          }
          secretsScope = {
            projectSlug = local.infisical_base.project_slug
            envSlug     = local.infisical_base.env_slug
            secretsPath = "/ai/langfuse"
          }
        }
      }
      managedSecretReference = {
        secretName      = "langfuse-app-secrets"
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })
  depends_on = [kubernetes_namespace_v1.ai]
}

resource "kubernetes_deployment_v1" "langfuse" {
  metadata {
    name      = "langfuse"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "langfuse" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "langfuse" }
    }
    template {
      metadata {
        labels = { app = "langfuse" }
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name  = "langfuse"
          image = "langfuse/langfuse:2"

          port {
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "NEXTAUTH_URL"
            value = "https://langfuse.noizu.com"
          }
          env {
            name  = "TELEMETRY_ENABLED"
            value = "false"
          }

          dynamic "env" {
            for_each = {
              DATABASE_URL    = "LANGFUSE_DATABASE_URL"
              NEXTAUTH_SECRET = "LANGFUSE_NEXTAUTH_SECRET"
              SALT            = "LANGFUSE_SALT"
              ENCRYPTION_KEY  = "LANGFUSE_ENCRYPTION_KEY"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "langfuse-app-secrets"
                  key  = env.value
                }
              }
            }
          }

          resources {
            requests = { cpu = "100m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          liveness_probe {
            http_get {
              path = "/api/public/health"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/api/public/health"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.langfuse_infisical]
}

resource "kubernetes_service_v1" "langfuse" {
  metadata {
    name      = "langfuse"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "langfuse" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "langfuse" }
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "langfuse" {
  metadata {
    name      = "langfuse-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "langfuse" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
      "nginx.ingress.kubernetes.io/auth-tls-verify-client" = "on"
      "nginx.ingress.kubernetes.io/auth-tls-secret"        = "${local.ns}/cloudflare-tls-synced"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["langfuse.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "langfuse.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.langfuse.metadata[0].name
              port { number = 3000 }
            }
          }
        }
      }
    }
  }
}
