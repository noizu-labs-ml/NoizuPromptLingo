# ---------------------------------------------------------------------------
# Platform-tier shared data services: platform-valkey + platform-timescaledb.
# ---------------------------------------------------------------------------
# Credentials are managed by Infisical (the operator syncs them from
# /platform/* into the managed Secrets these workloads consume). Requires the
# infisical operator + universal-auth-credentials (set up by infra-services).
resource "kubernetes_namespace_v1" "platform" {
  metadata {
    name = var.namespace
  }
}

module "platform_valkey" {
  source = "../../modules/valkey"

  name                = "platform-valkey"
  namespace           = kubernetes_namespace_v1.platform.metadata[0].name
  storage_class       = local.storage_class
  node_selector       = local.node_selector
  managed_secret_name = "platform-valkey-secrets"

  infisical = merge(local.infisical_base, { secrets_path = "/platform/valkey" })
}

module "platform_timescaledb" {
  source = "../../modules/timescaledb"

  name                = "platform-timescaledb"
  namespace           = kubernetes_namespace_v1.platform.metadata[0].name
  storage_class       = local.storage_class
  node_selector       = local.node_selector
  managed_secret_name = "platform-timescaledb-secrets"

  # Per-app DB provisioning, mirroring infra/postgres.tf: drop an
  # initdb.d/<app>/init-db.sh folder and add its <APP>_DB_USER / <APP>_DB_PASSWORD
  # keys to the Infisical /platform/postgres path (synced into
  # platform-timescaledb-secrets).
  initdb_scripts_dir = "${path.module}/files/postgres/initdb.d"

  infisical = merge(local.infisical_base, { secrets_path = "/platform/postgres" })
}

module "platform_mariadb" {
  source = "../../modules/mariadb"

  name                = "platform-mariadb"
  namespace           = kubernetes_namespace_v1.platform.metadata[0].name
  storage_class       = local.storage_class
  node_selector       = local.node_selector
  managed_secret_name = "platform-mariadb-secrets"

  # Per-app DB provisioning: drop an initdb.d/<app>/init-db.sh folder and add its
  # <APP>_DB_USER / <APP>_DB_PASSWORD keys to the Infisical /platform/mariadb path
  # (synced into platform-mariadb-secrets, alongside MARIADB_ROOT_PASSWORD).
  initdb_scripts_dir = "${path.module}/files/mariadb/initdb.d"

  infisical = merge(local.infisical_base, { secrets_path = "/platform/mariadb" })
}

module "platform_mongodb" {
  source = "../../modules/mongodb"

  name                = "platform-mongodb"
  namespace           = kubernetes_namespace_v1.platform.metadata[0].name
  storage_class       = local.storage_class
  node_selector       = local.node_selector
  managed_secret_name = "platform-mongodb-secrets"

  # Per-app DB provisioning: drop an initdb.d/<app>/init-db.sh folder and add its
  # <APP>_DB_USER / <APP>_DB_PASSWORD keys to the Infisical /platform/mongodb path
  # (synced into platform-mongodb-secrets, alongside MONGO_ROOT_USERNAME /
  # MONGO_ROOT_PASSWORD).
  initdb_scripts_dir = "${path.module}/files/mongodb/initdb.d"

  infisical = merge(local.infisical_base, { secrets_path = "/platform/mongodb" })
}
