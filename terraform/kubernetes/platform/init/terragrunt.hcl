# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `platform/init` stack (platform-tier data services).
# ---------------------------------------------------------------------------
# Like `infra` / `infra-services`, this stack declares its own `backend "s3"`
# (MinIO) block in provider.tf (key platform/init/terraform.tfstate), so root.hcl
# stays backend-agnostic and we do NOT generate a backend here. Supply the MinIO
# credentials as AWS_* env vars at apply time (they come from init's outputs):
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
#   terragrunt apply            # or from the repo root: terragrunt run --all apply
#
# Run ordering: this stack runs AFTER init / infra / infra-services.
#   * init           — bootstraps MinIO + the tfstate bucket and exposes the
#                      storage class + node selector this stack reads via
#                      terraform_remote_state (remote-state.tf).
#   * infra-services — installs the Infisical operator in infra + the
#                      universal-auth-credentials machine identity that this
#                      tier's workloads need to sync their managed Secrets.
#   * infra          — included for tier ordering (platform runs last).
# Terragrunt does NOT infer ordering from the data source, so we declare the
# edges explicitly below.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# This unit's Terraform references the shared modules at ../../modules
# (kubernetes/modules), which live OUTSIDE the unit dir. Terragrunt copies only
# the unit dir into its scratch cache, so a bare relative `../../modules` source
# can't be resolved there. Point the copy root at the `kubernetes` dir (two
# levels up) and run in the platform/init subdir (the `//` splits copy-root from
# run-subdir); now ../../modules resolves inside the copy.
terraform {
  source = "${get_terragrunt_dir()}/../..//platform/init"

  # Copy-root is the whole `kubernetes` dir (so ../../modules comes along), but we
  # only need modules/ + this unit. Skip the large/irrelevant siblings so the
  # scratch copy stays small — most importantly the ~35M cluster-backup dump.
  exclude_from_copy = [
    "cluster-backup-noizu-*",
    "infra",
    "infra-services",
    "init",
    "apps",
    "docs",
  ]
}

dependencies {
  paths = ["../../init", "../../infra", "../../infra-services"]
}

# Terraform runs from a .terragrunt-cache copy, so the in-tree relative path to
# init's local state breaks. get_terragrunt_dir() is THIS unit's real directory,
# so hand the stack the absolute path to the root init/terraform.tfstate. Merges
# with the kubeconfig inputs from root.hcl (non-overlapping keys).
inputs = {
  init_state_path = "${get_terragrunt_dir()}/../../init/terraform.tfstate"
}
