# ---------------------------------------------------------------------------
# Shared app namespace secrets synced by the Infisical operator.
# ---------------------------------------------------------------------------

# ops.noizu.com registry pull secret (/shared/registry) -> ops-registry-secret
# (kubernetes.io/dockerconfigjson). Keys: OPS_REGISTRY_USER, OPS_REGISTRY_PASSWORD.
resource "kubectl_manifest" "infisical_ops_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-ops-registry"
      namespace = kubernetes_namespace_v1.apps.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "ops-registry-secret"
        "app.kubernetes.io/component"  = "registry"
        "app.kubernetes.io/managed-by" = "terraform"
      }
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
        secretNamespace = kubernetes_namespace_v1.apps.metadata[0].name
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

  depends_on = [kubernetes_namespace_v1.apps]
}
