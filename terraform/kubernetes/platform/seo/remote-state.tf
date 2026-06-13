# Read the root init module's outputs (storage class, node selector). init uses a
# local backend, so we read its state file directly.
#
# Path resolution mirrors platform/init: plain `terraform` runs in this dir so the
# relative fallback works; Terragrunt injects the real absolute path via the
# init_state_path input.
data "terraform_remote_state" "init" {
  backend = "local"
  config = {
    path = coalesce(var.init_state_path, "${path.module}/../../init/terraform.tfstate")
  }
}

locals {
  storage_class = try(data.terraform_remote_state.init.outputs.storage_class, var.storage_class)
  node_selector = try(data.terraform_remote_state.init.outputs.node_selector, var.node_selector)

  infisical_base = {
    project_slug          = var.infisical_project_slug
    env_slug              = var.infisical_env_slug
    credentials_secret    = var.infisical_credentials_secret
    credentials_namespace = var.infisical_credentials_namespace
    resync_interval       = var.infisical_resync_interval
    host_api              = var.infisical_host_api
  }
}
