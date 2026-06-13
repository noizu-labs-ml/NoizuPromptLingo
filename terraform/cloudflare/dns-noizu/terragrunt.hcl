# ---------------------------------------------------------------------------
# Terragrunt wrapper — Cloudflare DNS for noizu.com
# ---------------------------------------------------------------------------
# 60+ DNS records (A, CNAME, MX, TXT, SRV) for the noizu.com zone.
# Backend: S3/MinIO at dns-noizu/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
