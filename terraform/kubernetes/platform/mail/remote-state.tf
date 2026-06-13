# Read the root init module's outputs (storage class). init uses a local backend.
data "terraform_remote_state" "init" {
  backend = "local"
  config = {
    path = coalesce(var.init_state_path, "${path.module}/../../init/terraform.tfstate")
  }
}
