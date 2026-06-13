# ---------------------------------------------------------------------------
# Qdrant — upstream chart (qdrant/qdrant 1.17.1), internal-only vector store.
# ClusterIP REST :6333 / gRPC :6334. Deployed via helm_release; the wrapper
# chart's only local template was the out-of-band InfisicalSecret below.
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "qdrant_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-qdrant-secrets"
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
            secretsPath = "/ai/qdrant"
          }
        }
      }
      managedSecretReference = {
        secretName      = "qdrant-app-secrets"
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

resource "helm_release" "qdrant" {
  name       = "qdrant"
  repository = "https://qdrant.github.io/qdrant-helm"
  chart      = "qdrant"
  version    = "1.17.1"
  namespace  = local.ns

  values = [
    templatefile("${path.module}/files/qdrant/values.yaml.tftpl", {
      storage_class = local.storage_class
    })
  ]

  depends_on = [kubectl_manifest.qdrant_infisical]
}
