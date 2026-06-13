# ---------------------------------------------------------------------------
# Terragrunt wrapper — Namecheap domain registration (placeholder)
# ---------------------------------------------------------------------------
# Provider configured for noizu + trl accounts. No resources yet.
# Backend: S3/MinIO at namecheap/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
