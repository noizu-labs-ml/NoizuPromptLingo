# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `platform/ai` stack (LLM/ML serving + tooling:
# vLLM, Open WebUI, JupyterHub, Langfuse, Qdrant, Weaviate, TTS, Livebook, …).
# ---------------------------------------------------------------------------
# Declares its own `backend "s3"` (MinIO) in provider.tf (key
# platform/ai/terraform.tfstate), so root.hcl stays backend-agnostic. Supply the
# MinIO credentials as AWS_* env vars at apply time (from init's outputs):
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
#   terragrunt apply            # or from the repo root: terragrunt run --all apply
#
# Run ordering: after init / infra / infra-services. This is a SELF-CONTAINED app
# stack — its workloads carry their own data stores and do NOT use the shared
# platform-init data services, so it carries no `../init` dependency. It only
# reads the root init outputs (storage class) and relies on the Infisical operator
# + universal-auth machine identity that infra-services installs.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../init", "../../infra", "../../infra-services"]
}

# Terragrunt runs Terraform from a .terragrunt-cache copy (even with no `source`
# block), so the in-tree relative path to init's local state breaks. Hand the
# stack the absolute path; remote-state.tf coalesces onto it. Merges with the
# kubeconfig inputs from root.hcl (non-overlapping keys).
inputs = {
  init_state_path = "${get_terragrunt_dir()}/../../init/terraform.tfstate"
}
