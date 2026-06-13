# =============================================================================
# cert-manager Certificate — Let's Encrypt cert for the mail hostname.
# =============================================================================
# Issued into the `mail-tls-letsencrypt` Secret, mounted (optional) by the front
# container for mail-protocol TLS.
# =============================================================================
resource "kubectl_manifest" "mail_tls_letsencrypt" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "mail-tls-letsencrypt"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      secretName = local.le_tls_secret
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [var.hostnames]
    }
  })

  depends_on = [kubernetes_namespace_v1.mail]
}
