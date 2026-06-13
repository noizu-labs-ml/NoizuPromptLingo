# ---------------------------------------------------------------------------
# Root Terragrunt config — shared across every stack in this repo.
# ---------------------------------------------------------------------------
# Included by each module's terragrunt.hcl via:
#   include "root" { path = find_in_parent_folders("root.hcl") }
#
# Intentionally backend-agnostic: it does NOT declare a `remote_state` block.
#   * `init` keeps LOCAL state (it bootstraps the MinIO bucket every other
#     module uses as its backend) and must not be handed an S3 backend.
#   * `infra` / `infra-services` already declare their own `backend "s3"` block
#     (pointed at MinIO) in their provider.tf, with credentials supplied via the
#     AWS_* env vars at `terragrunt init` time.
#
# Keep this file limited to settings that are correct for ALL stacks, including
# the local-state bootstrap module. Backend wiring belongs in the modules.

terraform_binary = get_env("TERRAGRUNT_TFPATH", "tofu")

locals {
  # The kubeconfig used to reach the cluster. Modules expose these as variables
  # (init: kube_config_path/kube_config_context; infra: kube_config_path/
  # kube_context) and Terraform auto-loads them from TF_VAR_* below.
  kube_config_path    = get_env("KUBE_CONFIG_PATH", "/Users/keithbrings/.kube/noizu/config")
  kube_config_context = get_env("KUBE_CONFIG_CONTEXT", "noizu")
}

# Surface the cluster target to every module as environment variables so a
# single export (or the defaults above) targets the whole tree. Terraform reads
# TF_VAR_<name>; names differ per module, so we set both spellings.
inputs = {
  kube_config_path    = local.kube_config_path
  kube_config_context = local.kube_config_context # init
  kube_context        = local.kube_config_context # infra / infra-services
}
