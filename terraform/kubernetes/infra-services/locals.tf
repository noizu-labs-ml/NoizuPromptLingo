locals {
  ns            = try(data.terraform_remote_state.init.outputs.namespace, var.namespace)
  storage_class = try(data.terraform_remote_state.init.outputs.storage_class, var.storage_class)
  node_selector = try(data.terraform_remote_state.init.outputs.node_selector, var.node_selector)

  common_labels = {
    "app.kubernetes.io/part-of"    = "noizu-infra-services"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
