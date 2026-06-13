# Platform namespace. Hosts MinIO object storage.
resource "kubernetes_namespace_v1" "infra" {
  metadata {
    name = "infra"
  }
}
