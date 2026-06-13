locals {
  # Single-source the namespace + storage class from the init module's outputs,
  # falling back to the variables if init's state isn't readable (standalone use).
  ns            = try(data.terraform_remote_state.init.outputs.namespace, var.namespace)
  storage_class = try(data.terraform_remote_state.init.outputs.storage_class, var.storage_class)
  node_selector = try(data.terraform_remote_state.init.outputs.node_selector, var.node_selector)

  # Common labels applied to everything in this module.
  common_labels = {
    "app.kubernetes.io/part-of"    = "noizu-infra"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
