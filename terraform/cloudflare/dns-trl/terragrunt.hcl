# ---------------------------------------------------------------------------
# Terragrunt wrapper — Cloudflare DNS for therobotlives.com
# ---------------------------------------------------------------------------
# Mail DNS records (MX, SPF, DKIM) for therobotlives.com zone.
# Backend: S3/MinIO at dns-trl/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
