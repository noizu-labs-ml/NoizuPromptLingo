# ---------------------------------------------------------------------------
# Apps-tier shared data services: app-valkey + app-timescaledb.
# ---------------------------------------------------------------------------
# Credentials are managed by Infisical (operator syncs /apps/* into the managed
# Secrets). Requires the infisical operator + universal-auth-credentials.
resource "kubernetes_namespace_v1" "apps" {
  metadata {
    name = var.namespace
  }
}

module "app_valkey" {
  source = "../../modules/valkey"

  name                = "app-valkey"
  namespace           = kubernetes_namespace_v1.apps.metadata[0].name
  storage_class       = local.storage_class
  managed_secret_name = "app-valkey-secrets"

  infisical = merge(local.infisical_base, { secrets_path = "/apps/valkey" })
}

module "app_timescaledb" {
  source = "../../modules/timescaledb"

  name                = "app-timescaledb"
  namespace           = kubernetes_namespace_v1.apps.metadata[0].name
  storage_class       = local.storage_class
  managed_secret_name = "app-timescaledb-secrets"

  infisical = merge(local.infisical_base, { secrets_path = "/apps/postgres" })
}
