# ---------------------------------------------------------------------------
# Read the init module's outputs (namespace, storage class, MinIO info).
# ---------------------------------------------------------------------------
# init uses a LOCAL backend, so we read its state file directly. This makes the
# namespace/storage class single-sourced from init rather than duplicated here.
#
# Path resolution: plain `terraform` runs in this directory, so the relative
# fallback works. Terragrunt runs Terraform from a .terragrunt-cache copy where
# path.module is NOT this dir, so it injects the real absolute path via the
# init_state_path input (see terragrunt.hcl / get_terragrunt_dir()).
#
# Note: this does NOT feed the s3 backend block (backends can't take data
# sources) — backend credentials still come from AWS_* env. It's runtime wiring
# for resource attributes only.
data "terraform_remote_state" "init" {
  backend = "local"
  config = {
    path = coalesce(var.init_state_path, "${path.module}/../init/terraform.tfstate")
  }
}
