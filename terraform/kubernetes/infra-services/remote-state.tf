# Read the init module's outputs (namespace, storage class, node selector). init
# uses a local backend, so we read its state file directly. Does not feed the s3
# backend block (backends can't take data sources) — runtime wiring only.
#
# Path resolution: plain `terraform` runs in this directory, so the relative
# fallback works. Terragrunt runs Terraform from a .terragrunt-cache copy where
# path.module is NOT this dir, so it injects the real absolute path via the
# init_state_path input (see terragrunt.hcl / get_terragrunt_dir()).
data "terraform_remote_state" "init" {
  backend = "local"
  config = {
    path = coalesce(var.init_state_path, "${path.module}/../init/terraform.tfstate")
  }
}
