# ---------------------------------------------------------------------------
# Terragrunt wrapper — Cloudflare zones for TheRobotLives domains
# ---------------------------------------------------------------------------
# 6 TRL-themed domains. Needs TRL account ID in locals.tf before use.
# Backend: S3/MinIO at zones-trl/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
