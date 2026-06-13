# ---------------------------------------------------------------------------
# therobotknows.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "therobotknows_site" {
  name      = "therobotknows"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.therobotknows_chart_path != "" ? var.therobotknows_chart_path : abspath("${path.module}/../../../../projects/therobotknows.com/helm/therobotknows")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "therobotknows"
        fullnameOverride = "therobotknows"
        domain           = var.therobotknows_domain
        image            = var.therobotknows_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.therobotknows_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/therobotknows"
            crtKey               = "THEROBOTKNOWS_TLS_CRT"
            keyKey               = "THEROBOTKNOWS_TLS_KEY"
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
