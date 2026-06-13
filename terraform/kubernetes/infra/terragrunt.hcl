# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `infra` stack.
# ---------------------------------------------------------------------------
# Unlike `init`, this stack declares its own `backend "s3"` (MinIO) block in
# provider.tf, so root.hcl stays backend-agnostic and we do NOT generate a
# backend here. Supply the MinIO credentials as AWS_* env vars at apply time
# (they come from init's outputs):
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../init output -raw minio_root_password)
#   terragrunt apply            # or from the parent: terragrunt run --all apply
#
# Run ordering: init MUST run before infra — init bootstraps MinIO + the tfstate
# bucket and generates the secret values (init/infra-creds.tf) that this stack
# reads via terraform_remote_state (remote-state.tf). Terragrunt does NOT infer
# ordering from that data source, so we declare it explicitly below.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../init"]
}

# Terraform runs from a .terragrunt-cache copy, so the in-tree relative path to
# init's local state breaks. get_terragrunt_dir() is THIS unit's real directory,
# so hand infra the absolute path to init/terraform.tfstate. Merges with the
# kubeconfig inputs from root.hcl (non-overlapping keys).
inputs = {
  init_state_path = "${get_terragrunt_dir()}/../init/terraform.tfstate"
}
