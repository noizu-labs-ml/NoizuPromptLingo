# ---------------------------------------------------------------------------
# therobotmakes.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "therobotmakes_site" {
  name      = "therobotmakes"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.therobotmakes_chart_path != "" ? var.therobotmakes_chart_path : abspath("${path.module}/../../../../projects/therobotmakes.com/helm/therobotmakes")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "therobotmakes"
        fullnameOverride = "therobotmakes"
        domain           = var.therobotmakes_domain
        image            = var.therobotmakes_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.therobotmakes_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/therobotmakes"
            crtKey               = "THEROBOTMAKES_TLS_CRT"
            keyKey               = "THEROBOTMAKES_TLS_KEY"
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
