# =============================================================================
# InfisicalSecret CRDs — the operator syncs Infisical -> managed K8s Secrets.
# =============================================================================
# Creates:
#   mail-app-secrets             (Opaque)             app secrets + derived DB URIs
#   ops-registry-secret          (dockerconfigjson)   ops.noizu.com image pull
#   cloudflare-tls-therobotlives (kubernetes.io/tls)  Cloudflare Origin CA cert
# =============================================================================

# --- Image pull secret: ops.noizu.com private registry ---
resource "kubectl_manifest" "infisical_ops_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-mail-ops-pull"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = var.infisical_resync_interval
      hostAPI        = var.infisical_host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = var.infisical_credentials_secret
            secretNamespace = var.infisical_credentials_namespace
          }
          secretsScope = {
            projectSlug = var.infisical_project_slug
            envSlug     = var.infisical_env_slug
            secretsPath = local.app_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = local.ops_pull_secret
        secretNamespace = local.ns
        secretType      = "kubernetes.io/dockerconfigjson"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            ".dockerconfigjson" = "{{ mustToJson (dict \"auths\" (dict \"ops.noizu.com\" (dict \"username\" .OPS_REGISTRY_USER.Value \"password\" .OPS_REGISTRY_PASSWORD.Value \"email\" \"keith.brings@noizu.com\" \"auth\" (printf \"%s:%s\" .OPS_REGISTRY_USER.Value .OPS_REGISTRY_PASSWORD.Value | b64enc)))) }}"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.mail]
}

# --- App secrets (all raw keys + derived connection strings) ---
resource "kubectl_manifest" "infisical_app_secrets" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-mail-secrets"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = var.infisical_resync_interval
      hostAPI        = var.infisical_host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = var.infisical_credentials_secret
            secretNamespace = var.infisical_credentials_namespace
          }
          secretsScope = {
            projectSlug = var.infisical_project_slug
            envSlug     = var.infisical_env_slug
            secretsPath = local.app_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = local.app_secret_name
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
          data = {
            SQLALCHEMY_DATABASE_URI = "postgresql://{{ .MAILU_DB_USER.Value }}:{{ .MAILU_DB_PASSWORD.Value }}@postgresql:5432/mailu"
            ROUNDCUBE_DB_URI        = "postgresql://{{ .ROUNDCUBE_DB_USER.Value }}:{{ .ROUNDCUBE_DB_PASSWORD.Value }}@postgresql:5432/roundcube"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.mail]
}

# --- Cloudflare Origin CA TLS secret for *.therobotlives.com ---
resource "kubectl_manifest" "infisical_cf_tls" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-mail-tls"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = var.infisical_resync_interval
      hostAPI        = var.infisical_host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = var.infisical_credentials_secret
            secretNamespace = var.infisical_credentials_namespace
          }
          secretsScope = {
            projectSlug = var.infisical_project_slug
            envSlug     = var.infisical_env_slug
            secretsPath = local.cf_tls_secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = local.cf_tls_secret
        secretNamespace = local.ns
        secretType      = "kubernetes.io/tls"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            "tls.crt" = "{{ .THEROBOTLIVES_TLS_CRT.Value }}"
            "tls.key" = "{{ .THEROBOTLIVES_TLS_KEY.Value }}"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.mail]
}
