# ---------------------------------------------------------------------------
# Terragrunt wrapper — Cloudflare Zero Trust Access
# ---------------------------------------------------------------------------
# Access applications, groups, and policies protecting platform services.
# Outputs livebook_zta_provider_string consumed by kubernetes/infra-services.
# Backend: S3/MinIO at zero-trust/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
