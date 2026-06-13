# ---------------------------------------------------------------------------
# gotta.cc static website.
# ---------------------------------------------------------------------------

resource "helm_release" "gottacc_site" {
  name      = "gotta-cc"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.gottacc_site_chart_path != "" ? var.gottacc_site_chart_path : abspath("${path.module}/../../../../projects/gotta.cc/helm/gotta-cc")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "gotta-cc"
        fullnameOverride = "gotta-cc"
        domain           = var.gottacc_site_domain
        image            = var.gottacc_site_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.gottacc_site_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/gottacc"
            crtKey               = "GOTTACC_TLS_CRT"
            keyKey               = "GOTTACC_TLS_KEY"
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
