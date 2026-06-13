# ---------------------------------------------------------------------------
# codefre.sh — Phoenix API + Next.js frontend.
# ---------------------------------------------------------------------------

# App secrets (/apps/codefresh) -> apps-app-secrets.
# Keys (from Infisical):
#   CODEFRESH_DB_USER, CODEFRESH_DB_PASSWORD,
#   CODEFRESH_SECRET_KEY_BASE, CODEFRESH_GUARDIAN_SECRET_KEY,
#   CODEFRESH_REDIS_URL
resource "kubectl_manifest" "infisical_codefresh_secrets" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-codefresh-secrets"
      namespace = kubernetes_namespace_v1.apps.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "apps-app-secrets"
        "app.kubernetes.io/component"  = "codefresh"
        "app.kubernetes.io/managed-by" = "terraform"
      }
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
            secretsPath = var.codefresh_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = var.codefresh_managed_secret_name
        secretNamespace = kubernetes_namespace_v1.apps.metadata[0].name
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.apps]
}

resource "helm_release" "codefresh_site" {
  name      = "codefresh"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.codefresh_chart_path != "" ? var.codefresh_chart_path : abspath("${path.module}/../../../../projects/codefre.sh/helm/codefresh")

  values = [
    yamlencode({
      domain   = var.codefresh_domain
      replicas = 1

      backend = {
        image = var.codefresh_backend_image
        port  = 4000
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }
      }

      frontend = {
        image = var.codefresh_frontend_image
        port  = 3000
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }

      migrate = {
        enabled = true
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }

      database = {
        host = "app-timescaledb"
        port = 5432
        name = "codefresh"
      }

      secrets = {
        name = var.codefresh_managed_secret_name
        keys = {
          dbUser           = "CODEFRESH_DB_USER"
          dbPassword       = "CODEFRESH_DB_PASSWORD"
          secretKeyBase    = "CODEFRESH_SECRET_KEY_BASE"
          guardianSecretKey = "CODEFRESH_GUARDIAN_SECRET_KEY"
          redisUrl         = "CODEFRESH_REDIS_URL"
        }
      }

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      ingress = {
        enabled       = true
        className     = "nginx"
        cloudflareOnly = true
        annotations = {
          "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
          "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
        }
      }

      tls = {
        enabled    = true
        secretName = var.codefresh_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/codefresh"
          crtKey               = "CODEFRESH_TLS_CRT"
          keyKey               = "CODEFRESH_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
    kubectl_manifest.infisical_codefresh_secrets,
  ]
}
