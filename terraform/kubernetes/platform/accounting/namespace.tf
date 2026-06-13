# ---------------------------------------------------------------------------
# Accounting-tier namespace. Holds ERPNext (helm_release), Kimai, and their
# supporting MariaDB / Valkey workloads. Secrets come from Infisical.
# ---------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "accounting" {
  metadata {
    name = var.namespace
  }
}
