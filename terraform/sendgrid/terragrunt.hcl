# ---------------------------------------------------------------------------
# Terragrunt wrapper — SendGrid email infrastructure
# ---------------------------------------------------------------------------
# API keys (11 infra + 20 portfolio) and DKIM domain authentication.
# Backend: S3/MinIO at sendgrid/terraform.tfstate

include "root" {
  path = find_in_parent_folders("root.hcl")
}
