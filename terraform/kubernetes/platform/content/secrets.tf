# ---------------------------------------------------------------------------
# Infisical-managed secrets. The operator syncs Infisical paths into the managed
# K8s Secrets the workloads consume.
# ---------------------------------------------------------------------------

# App secrets (/content) -> content-app-secrets.
# Keys: docmost(DOCMOST_DATABASE_URL, DOCMOST_REDIS_URL, DOCMOST_JWT_SECRET, SMTP_*);
#   ghost(GHOST_DB_PASSWORD); nextcloud(NEXTCLOUD_DB_USER/PASSWORD, NEXTCLOUD_REDIS_PASSWORD, NEXTCLOUD_ADMIN_USER/PASSWORD, SMTP_*).
resource "kubectl_manifest" "infisical_app_secrets" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-content-secrets"
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
            secretsPath = var.infisical_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = var.managed_secret_name
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.content]
}

# Shared wildcard TLS (*.noizu.com) (/shared/tls) -> cloudflare-tls-synced
# (kubernetes.io/tls). Referenced by every ingress' TLS block.
resource "kubectl_manifest" "infisical_tls_sync" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-tls-sync"
      namespace = local.ns
      labels    = local.common_labels
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
        secretNamespace = local.ns
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

  depends_on = [kubernetes_namespace_v1.content]
}

# ops.noizu.com registry pull secret (/shared/registry) -> ops-registry-secret
# (kubernetes.io/dockerconfigjson). Keys: OPS_REGISTRY_USER, OPS_REGISTRY_PASSWORD.
resource "kubectl_manifest" "infisical_ops_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-ops-registry"
      namespace = local.ns
      labels    = local.common_labels
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
            secretsPath = var.registry_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = "ops-registry-secret"
        secretNamespace = local.ns
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

  depends_on = [kubernetes_namespace_v1.content]
}
