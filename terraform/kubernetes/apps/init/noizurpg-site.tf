# ---------------------------------------------------------------------------
# noizurpg.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "noizurpg_site" {
  name      = "noizurpg"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.noizurpg_chart_path != "" ? var.noizurpg_chart_path : abspath("${path.module}/../../../../projects/noizurpg.com/helm/noizurpg")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "noizurpg"
        fullnameOverride = "noizurpg"
        domain           = var.noizurpg_domain
        image            = var.noizurpg_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.noizurpg_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/noizurpg"
            crtKey               = "NOIZURPG_TLS_CRT"
            keyKey               = "NOIZURPG_TLS_KEY"
            caKey                = ""
          }
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
