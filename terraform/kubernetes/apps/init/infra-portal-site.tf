# ---------------------------------------------------------------------------
# infra.noizu.com portal (static site, uses shared *.noizu.com TLS).
# ---------------------------------------------------------------------------

resource "helm_release" "infra_portal_site" {
  name      = "infra-portal"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  chart     = var.infra_portal_chart_path != "" ? var.infra_portal_chart_path : abspath("${path.module}/../../../../projects/infra.noizu.com/helm/infra-portal")

  values = [
    yamlencode({
      "static-site" = {
        nameOverride     = "infra-portal"
        fullnameOverride = "infra-portal"
        domain           = "infra.noizu.com"
        image            = var.infra_portal_image
        port             = 80

        imagePullSecrets = [
          { name = "ops-registry-secret" }
        ]

        tls = {
          secretName = "noizu-com-tls"
          infisical = {
            enabled = false
          }
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.infisical_ops_pull,
  ]
}
