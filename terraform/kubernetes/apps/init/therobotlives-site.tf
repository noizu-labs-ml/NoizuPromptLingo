# ---------------------------------------------------------------------------
# therobotlives.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "therobotlives_site" {
  name      = "therobotlives"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.therobotlives_chart_path != "" ? var.therobotlives_chart_path : abspath("${path.module}/../../../../projects/therobotlives.com/helm/therobotlives")

  values = [
    yamlencode({
      domain = var.therobotlives_domain
      image  = var.therobotlives_image
      port   = 80

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      tls = {
        secretName = var.therobotlives_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/therobotlives"
          crtKey               = "THEROBOTLIVES_TLS_CRT"
          keyKey               = "THEROBOTLIVES_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
