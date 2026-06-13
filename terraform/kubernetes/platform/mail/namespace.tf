# Mail-tier namespace. This module owns it.
resource "kubernetes_namespace_v1" "mail" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}
