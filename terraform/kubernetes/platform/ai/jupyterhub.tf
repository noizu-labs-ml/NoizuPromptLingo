# ---------------------------------------------------------------------------
# JupyterHub — upstream chart (jupyterhub/jupyterhub 4.3.2), served at
# jupyter.noizu.com. Deployed via helm_release; the wrapper chart had no local
# templates beyond the out-of-band InfisicalSecret reproduced below.
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "jupyterhub_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-jupyter-secrets"
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
            secretsPath = "/ai/jupyterhub"
          }
        }
      }
      managedSecretReference = {
        secretName      = "jupyter-app-secrets"
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

resource "helm_release" "jupyterhub" {
  name       = "jupyterhub"
  repository = "https://hub.jupyter.org/helm-chart/"
  chart      = "jupyterhub"
  version    = "4.3.2"
  namespace  = local.ns

  values = [
    templatefile("${path.module}/files/jupyterhub/values.yaml.tftpl", {
      storage_class = local.storage_class
      namespace     = local.ns
    })
  ]

  # The hub consumes the operator-managed jupyter-app-secrets at runtime.
  depends_on = [kubectl_manifest.jupyterhub_infisical]
}
