# ---------------------------------------------------------------------------
# Sealed Secrets — encrypted secret files consumed by this module.
# ---------------------------------------------------------------------------
# The sealed-secrets controller (installed by the init module) unseals these
# committed, encrypted files into real Secrets in the infra namespace. The
# sealed files are the source of truth for these credentials — Terraform only
# applies them, so an apply can never regenerate the values.
#
# Expected files in secrets/ (one SealedSecret each):
#   postgres-secrets     (POSTGRES_PASSWORD, <APP>_DB_USER/PASSWORD)  — postgres
#   clickhouse-secrets   (SIGNOZ_TOKENIZER_JWT_SECRET)               — clickhouse
#   registry-basic-auth  (auth = htpasswd)                           — registry ingress
#   ops-noizu-com-tls    (tls.crt, tls.key)                          — registry ingress
#
# Generate/refresh from the live cluster (needs kubeseal):
#   ./seal-managed-secrets.sh   # postgres / clickhouse / registry-basic-auth
#   ./seal-secrets.sh           # ops-noizu-com-tls (recovered cert)
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
