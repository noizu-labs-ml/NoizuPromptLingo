# ---------------------------------------------------------------------------
# robots-unite.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "robotsunite_site" {
  name      = "robots-unite"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.robotsunite_chart_path != "" ? var.robotsunite_chart_path : abspath("${path.module}/../../../../projects/robots-unite.com/helm/robots-unite")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "robots-unite"
        fullnameOverride = "robots-unite"
        domain           = var.robotsunite_domain
        image            = var.robotsunite_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.robotsunite_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/robotsunite"
            crtKey               = "ROBOTSUNITE_TLS_CRT"
            keyKey               = "ROBOTSUNITE_TLS_KEY"
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
