# ---------------------------------------------------------------------------
# Top-level Terragrunt config — shared across external provider stacks.
# ---------------------------------------------------------------------------
# Included by each external stack's terragrunt.hcl via:
#   include "root" { path = find_in_parent_folders("root.hcl") }
#
# Kubernetes stacks have their own kubernetes/root.hcl (found first by
# find_in_parent_folders) and never see this file.
#
# Backend-agnostic: every stack declares its own backend "s3" in its .tf files.
# Credentials come from TF_VAR_* env vars exported by .envrc.

terraform_binary = get_env("TERRAGRUNT_TFPATH", "tofu")
