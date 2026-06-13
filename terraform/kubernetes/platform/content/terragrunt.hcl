# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `platform/content` stack (platform-content).
# ---------------------------------------------------------------------------
# Declares its own `backend "s3"` (MinIO) in provider.tf (key
# platform/content/terraform.tfstate), so root.hcl stays backend-agnostic. Supply the
# MinIO credentials as AWS_* env vars at apply time (from init's outputs):
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
#   terragrunt apply            # or from the repo root: terragrunt run --all apply
#
# Run ordering: after init / infra / infra-services / platform-init (this stack
# uses the shared platform-mariadb from platform/init).

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../init", "../../infra", "../../infra-services", "../init"]
}

# Terraform runs in this dir (no source block), but pass the absolute init state
# path explicitly so it works under `run --all` too.
inputs = {
  init_state_path = "${get_terragrunt_dir()}/../../init/terraform.tfstate"
}
