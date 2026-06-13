# ---------------------------------------------------------------------------
# derobot.is teaser page.
# ---------------------------------------------------------------------------

resource "helm_release" "derobotis_site" {
  name      = "derobotis"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.derobotis_chart_path != "" ? var.derobotis_chart_path : abspath("${path.module}/../../../../projects/derobot.is/helm/derobotis")

  values = [
    yamlencode({
      domain = var.derobotis_domain

      teaser = {
        image = var.derobotis_image
        port  = 8080
      }

      ingress = {
        cloudflareOnly = false
      }

      imagePullSecrets = [
        { name = "ops-registry-secret" }
      ]

      tls = {
        secretName = var.derobotis_tls_secret_name
        infisical = {
          enabled              = true
          resyncInterval       = 300
          hostAPI              = local.infisical_base.host_api
          credentialsSecret    = local.infisical_base.credentials_secret
          credentialsNamespace = local.infisical_base.credentials_namespace
          projectSlug          = local.infisical_base.project_slug
          envSlug              = local.infisical_base.env_slug
          secretsPath          = "/apps/tls/derobotis"
          crtKey               = "DEROBOTIS_TLS_CRT"
          keyKey               = "DEROBOTIS_TLS_KEY"
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
