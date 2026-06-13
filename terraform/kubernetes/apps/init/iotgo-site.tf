# ---------------------------------------------------------------------------
# iotgo.io static website.
# ---------------------------------------------------------------------------

resource "helm_release" "iotgo_site" {
  name      = "iotgo"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.iotgo_site_chart_path != "" ? var.iotgo_site_chart_path : abspath("${path.module}/../../../../projects/iotgo.io/helm/iotgo")

  values = [
    yamlencode({
      domain = var.iotgo_site_domain
      image  = var.iotgo_site_image
      port   = 80

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      tls = {
        secretName = var.iotgo_site_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/iotgo"
          crtKey               = "IOTGO_TLS_CRT"
          keyKey               = "IOTGO_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
