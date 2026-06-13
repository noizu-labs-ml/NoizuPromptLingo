# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `init` (bootstrap) module.
# ---------------------------------------------------------------------------
# This module is the bootstrap and is deliberately NOT like the downstream
# stacks: it keeps LOCAL Terraform state, because it is what deploys MinIO and
# creates the `tfstate` bucket every other module uses as its S3 backend.
#
# IMPORTANT — state location:
#   Terragrunt runs Terraform inside a per-unit .terragrunt-cache copy, NOT in
#   this directory. A bare local backend would therefore write state into the
#   cache, leaving init/terraform.tfstate stale — and the `infra` /
#   `infra-services` modules read init's outputs from ../init/terraform.tfstate
#   via terraform_remote_state. To keep that contract, we generate a local
#   backend whose path is pinned to THIS directory with get_terragrunt_dir()
#   (an absolute path), so state always lands at init/terraform.tfstate
#   regardless of where Terraform executes.
#
#   We do NOT set `terraform { source }` (no external module to fetch) and we do
#   NOT use an S3 backend (init bootstraps the bucket — chicken-and-egg).
#
# Secrets (minio_root_password, the wildcard TLS key) live in the gitignored
# terraform.tfvars in this directory, which Terraform auto-loads.
#
#   cd init && terragrunt apply        # or from the parent: terragrunt run --all apply
#
# Override the cluster target without editing files:
#   KUBE_CONFIG_PATH=... KUBE_CONFIG_CONTEXT=... terragrunt apply

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Local backend pinned to the real init dir (see header). get_terragrunt_dir()
# resolves to this file's directory, so state is written to
# init/terraform.tfstate even though Terraform runs from .terragrunt-cache.
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
