# ---------------------------------------------------------------------------
# Terragrunt wrapper — Cloudflare zones for Noizu portfolio domains
# ---------------------------------------------------------------------------
# 39 portfolio domains managed via for_each. Needs terraform import before
# first apply (use import.tf / generate-imports.sh).
# Backend: S3/MinIO at zones-noizu/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
