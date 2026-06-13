# TLS cert for tobor.locker (/apps/tls/toborlocker) -> toborlocker-tls
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
            secretsPath = "/apps/tls/toborlocker"
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
            "tls.crt" = "{{ .TOBORLOCKER_TLS_CRT.Value }}"
            "tls.key" = "{{ .TOBORLOCKER_TLS_KEY.Value }}"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.tobor_locker]
}

# ops.noizu.com registry pull secret
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

  depends_on = [kubernetes_namespace_v1.tobor_locker]
}

# App secrets (/tobor-locker/app) -> tobor-locker-secrets
resource "kubectl_manifest" "infisical_app" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-tobor-locker"
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
            secretsPath = "/tobor-locker/app"
          }
        }
      }
      managedSecretReference = {
        secretName      = "tobor-locker-secrets"
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.tobor_locker]
}
