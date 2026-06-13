# ---------------------------------------------------------------------------
# Infisical-managed secrets. The operator syncs Infisical paths into the
# managed K8s Secrets that the workloads below consume.
# ---------------------------------------------------------------------------

# App secrets (/accounting) -> accounting-app-secrets.
# Keys (from Infisical): MARIADB_ROOT_PASSWORD, ERPNEXT_ADMIN_PASSWORD,
#   KIMAI_MARIADB_ROOT_PASSWORD, KIMAI_DATABASE_PASSWORD, KIMAI_ADMIN_EMAIL,
#   KIMAI_ADMIN_PASSWORD, KIMAI_APP_SECRET, SMTP_HOST, SMTP_PORT, SMTP_USER,
#   SMTP_PASSWORD, SMTP_FROM.
# A template synthesizes the Kimai DATABASE_URL from KIMAI_DATABASE_PASSWORD.
resource "kubectl_manifest" "infisical_app_secrets" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-accounting-secrets"
      namespace = var.namespace
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
            secretsPath = var.infisical_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = var.managed_secret_name
        secretNamespace = var.namespace
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
          data = {
            KIMAI_DATABASE_URL = "mysql://kimai:{{ .KIMAI_DATABASE_PASSWORD.Value }}@kimai-mariadb:3306/kimai"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.accounting]
}

# Shared wildcard TLS (*.noizu.com) (/shared/tls) -> cloudflare-tls-synced
# (kubernetes.io/tls). Referenced by both ingresses' TLS blocks.
resource "kubectl_manifest" "infisical_tls_sync" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-tls-sync"
      namespace = var.namespace
    }
    spec = {
      resyncInterval = 300
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
            secretsPath = "/shared/tls"
          }
        }
      }
      managedSecretReference = {
        secretName      = var.tls_secret_name
        secretNamespace = var.namespace
        secretType      = "kubernetes.io/tls"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            "tls.crt" = "{{ .TLS_CRT.Value }}"
            "tls.key" = "{{ .TLS_KEY.Value }}"
            "ca.crt"  = "{{ .CLOUDFLARE_CA_CRT.Value }}"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.accounting]
}

# ops.noizu.com registry pull secret (/shared/registry) -> ops-registry-secret
resource "kubectl_manifest" "infisical_ops_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-ops-registry"
      namespace = var.namespace
    }
    spec = {
      resyncInterval = 300
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
            secretsPath = "/shared/registry"
          }
        }
      }
      managedSecretReference = {
        secretName      = "ops-registry-secret"
        secretNamespace = var.namespace
        secretType      = "kubernetes.io/dockerconfigjson"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            ".dockerconfigjson" = "{{ mustToJson (dict \"auths\" (dict \"ops.noizu.com\" (dict \"username\" .OPS_REGISTRY_USER.Value \"password\" .OPS_REGISTRY_PASSWORD.Value \"email\" \"keith.brings@noizu.com\" \"auth\" (printf \"%s:%s\" .OPS_REGISTRY_USER.Value .OPS_REGISTRY_PASSWORD.Value | b64enc)))) }}\n"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.accounting]
}
