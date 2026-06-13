# ---------------------------------------------------------------------------
# Shared Infisical-managed secrets for the creative tier.
# ---------------------------------------------------------------------------
# Unlike the simpler app groups, creative apps each have their own secret set
# (mermaid uses envFrom; penpot/webstudio have distinct keys), so per-app
# InfisicalSecrets are created here (pulling /creative/<app> -> <app>-secrets) via
# for_each. Only the cluster-wide TLS cert and the ops.noizu.com pull secret are
# truly shared.

# Shared wildcard TLS (*.noizu.com) (/shared/tls) -> cloudflare-tls-synced.
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

  depends_on = [kubernetes_namespace_v1.creative]
}

# ops.noizu.com registry pull secret (/shared/registry) -> ops-registry-secret.
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

  depends_on = [kubernetes_namespace_v1.creative]
}

# Per-app InfisicalSecret: pulls /creative/<app> into <app>-secrets. Apps without
# secrets (chartdb, kroki, mydraft, plantuml) are simply absent from the set.
resource "kubectl_manifest" "infisical_app" {
  for_each = toset(var.app_secret_names)

  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-${each.key}"
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
            secretsPath = "/creative/${each.key}"
          }
        }
      }
      managedSecretReference = {
        secretName      = "${each.key}-secrets"
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.creative]
}
