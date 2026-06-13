# ---------------------------------------------------------------------------
# bladeofeternity.com Next.js website.
# ---------------------------------------------------------------------------

resource "helm_release" "bladeofeternity_site" {
  name      = "bladeofeternity"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.bladeofeternity_chart_path != "" ? var.bladeofeternity_chart_path : abspath("${path.module}/../../../../projects/bladeofeternity.com/helm/bladeofeternity")

  values = [
    yamlencode({
      domain = var.bladeofeternity_domain
      image  = var.bladeofeternity_image
      port   = 3000

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      tls = {
        secretName = var.bladeofeternity_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/bladeofeternity"
          crtKey               = "BLADEOFETERNITY_TLS_CRT"
          keyKey               = "BLADEOFETERNITY_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
