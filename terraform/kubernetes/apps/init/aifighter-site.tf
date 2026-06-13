# ---------------------------------------------------------------------------
# aifighter.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "aifighter_site" {
  name      = "aifighter"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.aifighter_site_chart_path != "" ? var.aifighter_site_chart_path : abspath("${path.module}/../../../../projects/aifighter.com/helm/aifighter")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "aifighter"
        fullnameOverride = "aifighter"
        domain           = var.aifighter_site_domain
        image            = var.aifighter_site_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.aifighter_site_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/aifighter"
            crtKey               = "AIFIGHTER_TLS_CRT"
            keyKey               = "AIFIGHTER_TLS_KEY"
            caKey                = "CLOUDFLARE_CA_CRT"
          }
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
