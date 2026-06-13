# ---------------------------------------------------------------------------
# Shared *.noizu.com wildcard TLS for platform-ai ingresses.
# ---------------------------------------------------------------------------
# Every platform-ai ingress (nb.noizu.com, langfuse, kitten-tts, jupyter,
# webui, ...) references the `cloudflare-tls-synced` secret for TLS. The module
# previously never created it, so ingress-nginx fell back to its self-signed
# "Fake Certificate" for those hosts. This InfisicalSecret syncs the Cloudflare
# origin wildcard cert from Infisical (/shared/tls → SANs *.noizu.com,noizu.com)
# into a kubernetes.io/tls secret, matching the platform/accounting module.
resource "kubectl_manifest" "infisical_tls_sync" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-tls-sync"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = 300
      hostAPI        = local.infisical_base.host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = local.infisical_base.credentials_secret
            secretNamespace = local.infisical_base.credentials_namespace
          }
          secretsScope = {
            projectSlug = local.infisical_base.project_slug
            envSlug     = local.infisical_base.env_slug
            secretsPath = "/shared/tls"
          }
        }
      }
      managedSecretReference = {
        secretName      = "cloudflare-tls-synced"
        secretNamespace = local.ns
        secretType      = "kubernetes.io/tls"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            "tls.crt" = "{{ .TLS_CRT.Value }}"
            "tls.key" = "{{ .TLS_KEY.Value }}"
            "ca.crt"  = "{{ .CLOUDFLARE_CA_CRT.Value }}"
          }
        }
      }
    }
  })

  depends_on = [kubernetes_namespace_v1.ai]
}
