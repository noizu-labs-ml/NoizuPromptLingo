# ---------------------------------------------------------------------------
# jailbreakingsite.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "jailbreakingsite_site" {
  name      = "jailbreakingsite"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.jailbreakingsite_chart_path != "" ? var.jailbreakingsite_chart_path : abspath("${path.module}/../../../../projects/jailbreakingsite.com/helm/jailbreakingsite")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "jailbreakingsite"
        fullnameOverride = "jailbreakingsite"
        domain           = var.jailbreakingsite_domain
        image            = var.jailbreakingsite_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = var.jailbreakingsite_tls_secret_name
          infisical = {
            enabled              = true
            resyncInterval       = 300
            hostAPI              = local.infisical_base.host_api
            credentialsSecret    = local.infisical_base.credentials_secret
            credentialsNamespace = local.infisical_base.credentials_namespace
            projectSlug          = local.infisical_base.project_slug
            envSlug              = local.infisical_base.env_slug
            secretsPath          = "/apps/tls/jailbreakingsite"
            crtKey               = "JAILBREAKINGSITE_TLS_CRT"
            keyKey               = "JAILBREAKINGSITE_TLS_KEY"
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
