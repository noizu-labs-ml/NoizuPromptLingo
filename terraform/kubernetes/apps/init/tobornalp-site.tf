# ---------------------------------------------------------------------------
# tobornalp.com — Phoenix API + Next.js frontend (start-app scaffold).
# ---------------------------------------------------------------------------

# App secrets (/apps/start-app) -> start-app-secrets.
resource "kubectl_manifest" "infisical_tobornalp_secrets" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-tobornalp-secrets"
      namespace = kubernetes_namespace_v1.apps.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "start-app-secrets"
        "app.kubernetes.io/component"  = "tobornalp"
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
            secretsPath = "/apps/start-app"
          }
        }
      }
      managedSecretReference = {
        secretName      = "start-app-secrets"
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

resource "helm_release" "tobornalp_site" {
  name      = "tobornalp"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.tobornalp_chart_path != "" ? var.tobornalp_chart_path : abspath("${path.module}/../../../../projects/tobornalp.com/app/helm/start-app")

  values = [
    yamlencode({
      domain   = var.tobornalp_domain
      replicas = 1

      backend = {
        image = var.tobornalp_backend_image
        port  = 4000
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }
      }

      frontend = {
        image = var.tobornalp_frontend_image
        port  = 3000
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }

      migrate = {
        enabled = false
      }

      database = {
        host = "app-timescaledb"
        port = 5432
        name = "tobornalp"
      }

      secrets = {
        name = "start-app-secrets"
        keys = {
          dbUser           = "START_APP_DB_USER"
          dbPassword       = "START_APP_DB_PASSWORD"
          secretKeyBase    = "START_APP_SECRET_KEY_BASE"
          guardianSecretKey = "START_APP_GUARDIAN_SECRET_KEY"
          redisUrl         = "START_APP_REDIS_URL"
          databaseUrl      = "START_APP_DATABASE_URL"
        }
      }

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      ingress = {
        enabled        = true
        className      = "nginx"
        cloudflareOnly = true
        annotations = {
          "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
          "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
        }
      }

      tls = {
        enabled    = true
        secretName = var.tobornalp_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/tobornalp"
          crtKey               = "TOBORNALP_TLS_CRT"
          keyKey               = "TOBORNALP_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
    kubectl_manifest.infisical_tobornalp_secrets,
  ]
}
