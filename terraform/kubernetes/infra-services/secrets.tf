# ---------------------------------------------------------------------------
# Sealed Secrets — encrypted secret files consumed by this module.
# ---------------------------------------------------------------------------
# The sealed-secrets controller (installed by init) unseals these committed,
# encrypted files into Secrets in the infra namespace. The sealed files are the
# source of truth — Terraform only applies them, so an apply can never
# regenerate the values. Generate/refresh with ./seal-secrets.sh (generate-once
# + seal; see README for the value sources). Run ../infra/seal-managed-secrets.sh
# first — it produces the shared DB creds + SigNoz JWT this module reuses.
#
# Expected files (one SealedSecret each):
#   authentik              connection config (envFrom)
#   authentik-secrets      DB creds + secret key + bootstrap + SendGrid
#   phoenix-secrets        DB URL + secrets + Google OAuth + SMTP
#   posthog-secrets        DB URL + secret key
#   infisical-core-secrets ENCRYPTION_KEY + AUTH_SECRET + shared-DB URL (REDIS_URL
#                          is built in Terraform from init's valkey password)
#   signoz-secrets         SIGNOZ_TOKENIZER_JWT_SECRET
#   verdaccio-htpasswd     htpasswd (basic auth)
#   cloudflare-tls-synced  *.noizu.com wildcard TLS (recovered from backup)
#   derobotis-tls          *.derobot.is wildcard TLS (recovered from backup)
# NOT here: authentik-valkey / posthog-valkey come from valkey-users.tf (init).
locals {
  sealed_secret_files = fileset("${path.module}/secrets", "*.sealedsecret.yaml")
}

data "kubectl_file_documents" "sealed" {
  for_each = local.sealed_secret_files
  content  = file("${path.module}/secrets/${each.value}")
}

resource "kubectl_manifest" "sealed" {
  for_each = {
    for item in flatten([
      for fname, doc in data.kubectl_file_documents.sealed : [
        for id, body in doc.manifests : {
          key  = "${fname}::${id}"
          body = body
        }
      ]
    ]) : item.key => item.body
  }
  yaml_body = each.value
}
