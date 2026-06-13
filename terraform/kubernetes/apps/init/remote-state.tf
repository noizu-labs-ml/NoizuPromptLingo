# Read the root init module's outputs (storage class). init uses a local backend.
data "terraform_remote_state" "init" {
  backend = "local"
  config = {
    path = var.init_state_path != "" ? var.init_state_path : "${path.module}/../../init/terraform.tfstate"
  }
}

locals {
  storage_class = try(data.terraform_remote_state.init.outputs.storage_class, var.storage_class)

  infisical_base = {
    host_api              = var.infisical_host_api
    project_slug          = var.infisical_project_slug
    env_slug              = var.infisical_env_slug
    credentials_secret    = var.infisical_credentials_secret
    credentials_namespace = var.infisical_credentials_namespace
    resync_interval       = var.infisical_resync_interval
  }
}
