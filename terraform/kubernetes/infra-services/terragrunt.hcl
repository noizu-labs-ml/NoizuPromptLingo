# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `infra-services` stack (the platform apps).
# ---------------------------------------------------------------------------
# Like `infra`, this stack declares its own `backend "s3"` (MinIO) block in
# provider.tf, so root.hcl stays backend-agnostic and we do NOT generate a
# backend here. Supply the MinIO credentials as AWS_* env vars at apply time
# (they come from init's outputs):
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../init output -raw minio_root_password)
#   terragrunt apply            # or from the parent: terragrunt run --all apply
#
# Run ordering: this stack runs LAST. It reads init's outputs directly via
# terraform_remote_state (remote-state.tf: namespace, storage class, node
# selector, shared valkey users) AND its apps connect to the shared data tier
# that `infra` stands up (postgres, valkey, clickhouse). Terragrunt does NOT
# infer ordering from the data source, so we declare both edges explicitly.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  before_hook "mark_fresh_infisical_service" {
    commands = ["apply"]
    execute = [
      "bash",
      "-c",
      "marker='${get_terragrunt_dir()}/.terragrunt-infisical-service-fresh'; ${get_env("TERRAGRUNT_TFPATH", "terraform")} state show kubernetes_service_v1.infisical >/dev/null 2>&1 || touch \"$marker\"",
    ]
  }

  after_hook "populate_infisical_secrets_on_fresh_service" {
    commands = ["apply"]
    execute = [
      "bash",
      "-c",
      "marker='${get_terragrunt_dir()}/.terragrunt-infisical-service-fresh'; if [ -f \"$marker\" ]; then kubectl rollout status deployment/infisical -n \"${get_env("INFISICAL_NAMESPACE", "infra")}\" --timeout=10m; infisical-populate-secrets --env=\"${get_env("INFISICAL_ENV", "prod")}\"; rm -f \"$marker\"; fi",
    ]
  }
}

dependencies {
  paths = ["../init", "../infra"]
}

# Terraform runs from a .terragrunt-cache copy, so the in-tree relative path to
# init's local state breaks. get_terragrunt_dir() is THIS unit's real directory,
# so hand the stack the absolute path to init/terraform.tfstate. Merges with the
# kubeconfig inputs from root.hcl (non-overlapping keys).
inputs = {
  init_state_path = "${get_terragrunt_dir()}/../init/terraform.tfstate"
}
