# ---------------------------------------------------------------------------
# noizu.com static website.
# ---------------------------------------------------------------------------

resource "helm_release" "noizu_site" {
  name      = "noizu-site"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.noizu_site_chart_path != "" ? var.noizu_site_chart_path : abspath("${path.module}/../../../../projects/noizu.com/helm/noizu-site")

  values = [
    yamlencode({
      domain = var.noizu_site_domain
      image  = var.noizu_site_image
      port   = 80

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      tls = {
        secretName = var.noizu_site_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/shared/tls"
          crtKey               = "TLS_CRT"
          keyKey               = "TLS_KEY"
          caKey                = "CLOUDFLARE_CA_CRT"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
