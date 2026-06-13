# ---------------------------------------------------------------------------
# Terragrunt wrapper — SigNoz monitoring
# ---------------------------------------------------------------------------
# Alert rules, notification channels, dashboards, and retention policies.
# Provider: SigNoz/signoz ~> 0.0.11 (official registry).
# Backend: S3/MinIO at monitoring/terraform.tfstate
#
# State migration: if monitoring/terraform.tfstate exists locally from the
# old repo, run `terragrunt init -migrate-state` to push it to S3.

include "root" {
  path = find_in_parent_folders("root.hcl")
}
