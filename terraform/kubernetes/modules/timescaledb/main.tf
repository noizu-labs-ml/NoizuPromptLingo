# ---------------------------------------------------------------------------
# TimescaleDB (HA + Apache AGE) with Infisical-managed credentials.
# ---------------------------------------------------------------------------
# Image runs as uid/gid 1000 with PGDATA=/home/postgres/pgdata/data, so the
# volume mounts at /home/postgres/pgdata. timescaledb/age are auto-preloaded.
locals {
  labels = merge(var.labels, {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/component"  = "database"
    "app.kubernetes.io/managed-by" = "terraform"
  })
  selector = { "app.kubernetes.io/name" = var.name }

  # Per-app DB provisioning (mirrors infra/postgres.tf). The folder name under
  # initdb.d/ is the single source of truth for both the script set and the
  # <APP>_DB_USER / <APP>_DB_PASSWORD env keys.
  app_scripts   = var.initdb_scripts_dir == "" ? [] : sort(tolist(fileset(var.initdb_scripts_dir, "*/init-db.sh")))
  app_dbs       = [for f in local.app_scripts : upper(dirname(f))]
  app_env_keys  = flatten([for a in local.app_dbs : ["${a}_DB_USER", "${a}_DB_PASSWORD"]])
  app_db_secret = var.app_db_secret_name != "" ? var.app_db_secret_name : var.managed_secret_name

  # uuid-ossp + pgcrypto are commonly needed; timescaledb/age are preloaded. The
  # shared lib is "_lib" (no .sh) so the base runner ignores it; per-app scripts
  # source it and are keyed "1NN-<app>.sh" to run after the image's baked 0xx set.
  extensions_file = {
    "00-extensions.sql" = <<-SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    SQL
  }
  lib_file = (length(local.app_scripts) > 0 && fileexists("${var.initdb_scripts_dir}/_lib.sh")) ? {
    "_lib" = file("${var.initdb_scripts_dir}/_lib.sh")
  } : {}
  app_files = {
    for i, f in local.app_scripts :
    format("1%02d-%s.sh", i, dirname(f)) => file("${var.initdb_scripts_dir}/${f}")
  }
  initdb_files = merge(local.extensions_file, local.lib_file, local.app_files)
}

resource "kubectl_manifest" "infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-${var.name}"
      namespace = var.namespace
      labels    = local.labels
    }
    spec = {
      hostAPI        = var.infisical.host_api
      resyncInterval = var.infisical.resync_interval
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = var.infisical.credentials_secret
            secretNamespace = var.infisical.credentials_namespace
          }
          secretsScope = {
            projectSlug = var.infisical.project_slug
            envSlug     = var.infisical.env_slug
            secretsPath = var.infisical.secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = var.managed_secret_name
        secretNamespace = var.namespace
        creationPolicy  = "Owner"
      }
    }
  })
}

resource "kubernetes_config_map_v1" "init" {
  metadata {
    name      = "${var.name}-init"
    namespace = var.namespace
    labels    = local.labels
  }
  data = local.initdb_files
}

resource "kubernetes_persistent_volume_claim_v1" "data" {
  metadata {
    name      = "${var.name}-data"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    resources {
      requests = { storage = var.storage_size }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "timescaledb" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = local.selector
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        node_selector = var.node_selector
        security_context {
          fs_group     = 1000
          run_as_user  = 1000
          run_as_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 1000:1000 /home/postgres/pgdata"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/home/postgres/pgdata"
          }
        }
        container {
          name  = "timescaledb"
          image = var.image

          # The base timescaledb-ha image does NOT inherit CMD=["postgres"], so
          # the wrapper entrypoint would exec the base entrypoint with no args
          # and exit 0 without starting the server. Pass the command explicitly.
          args = ["postgres"]

          port {
            name           = "postgresql"
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = var.superuser
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = var.password_key
              }
            }
          }
          dynamic "env" {
            for_each = var.database != "" ? [var.database] : []
            content {
              name  = "POSTGRES_DB"
              value = env.value
            }
          }
          env {
            name  = "TIMESCALEDB_TELEMETRY"
            value = "off"
          }

          # Per-app DB users/passwords consumed by the initdb.d scripts.
          dynamic "env" {
            for_each = toset(local.app_env_keys)
            content {
              name = env.value
              value_from {
                secret_key_ref {
                  name = local.app_db_secret
                  key  = env.value
                }
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/home/postgres/pgdata"
          }
          # Bin-place each file individually (subPath) so the image's baked
          # /docker-entrypoint-initdb.d/0xx first-boot scripts are preserved.
          dynamic "volume_mount" {
            for_each = local.initdb_files
            content {
              name       = "init"
              mount_path = "/docker-entrypoint-initdb.d/${volume_mount.key}"
              sub_path   = volume_mount.key
            }
          }

          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          liveness_probe {
            exec { command = ["sh", "-c", "pg_isready -U ${var.superuser}"] }
            initial_delay_seconds = 45
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "pg_isready -U ${var.superuser}"] }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.data.metadata[0].name
          }
        }
        volume {
          name = "init"
          config_map {
            name         = kubernetes_config_map_v1.init.metadata[0].name
            default_mode = "0755"
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "timescaledb" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector = local.selector
    port {
      name        = "postgresql"
      port        = 5432
      target_port = 5432
    }
  }
}
