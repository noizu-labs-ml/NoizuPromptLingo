# ---------------------------------------------------------------------------
# PostgreSQL — shared multi-tenant DB on TimescaleDB-HA + Apache AGE.
# ---------------------------------------------------------------------------
# Image: noizu/timescaledb-ha-with-age. Unlike the stock timescaledb image this
# runs as uid/gid 1000 with PGDATA=/home/postgres/pgdata/data, so the volume is
# mounted at /home/postgres/pgdata. Per-app databases/roles are created by the
# initdb.d scripts (below) from the postgres-secrets values passed as env.
locals {
  pg_image = "docker.io/noizu/timescaledb-ha-with-age:pg17.9-ts2.25.2-all-age1.7.0-r2"

  # Per-app DB provisioning lives one-file-per-app under files/postgres/initdb.d/
  # <app>/init-db.sh, with shared helpers in _lib.sh. The folder name is the
  # single source of truth: it drives both the initdb script set AND the
  # <APP>_DB_USER / <APP>_DB_PASSWORD env keys read from the postgres-secrets
  # sealed secret. Adding an app = drop an initdb.d/<app>/init-db.sh folder and
  # add its two keys to the sealed secret.
  pg_initdb_dir   = "${path.module}/files/postgres/initdb.d"
  pg_app_scripts  = sort(tolist(fileset(local.pg_initdb_dir, "*/init-db.sh")))
  pg_app_dbs      = [for f in local.pg_app_scripts : upper(dirname(f))]
  pg_app_env_keys = flatten([for a in local.pg_app_dbs : ["${a}_DB_USER", "${a}_DB_PASSWORD"]])

  # ConfigMap payload, one entry per file. Each is bin-placed individually (via
  # subPath) into /docker-entrypoint-initdb.d/ so the image's own first-boot
  # 0xx scripts (preload libs, perf tuning, extensions) are NOT shadowed. The
  # shared lib is "_lib" (no .sh) so the base runner ignores it; per-app scripts
  # source it and are keyed "1NN-<app>.sh" to run after the image's 0xx set.
  pg_initdb_files = merge(
    { "_lib" = file("${local.pg_initdb_dir}/_lib.sh") },
    {
      for i, f in local.pg_app_scripts :
      format("1%02d-%s.sh", i, dirname(f)) => file("${local.pg_initdb_dir}/${f}")
    },
  )
}

resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  metadata {
    name      = "infra-timescaledb-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "postgres" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "20Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_config_map_v1" "postgres_init" {
  metadata {
    name      = "infra-timescaledb-init"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "postgres" })
  }
  data = local.pg_initdb_files
}

resource "kubernetes_deployment_v1" "postgres" {
  metadata {
    name      = "infra-timescaledb"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "postgres" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "postgres" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "postgres" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group     = 1000
          run_as_user  = 1000
          run_as_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 1000:1000 /home/postgres/pgdata"]
          security_context {
            run_as_user = 0
          }
          volume_mount {
            name       = "data"
            mount_path = "/home/postgres/pgdata"
          }
        }
        container {
          name  = "timescaledb"
          image = local.pg_image

          # The image's ENTRYPOINT (timescaledb-ha-age-entrypoint.sh) execs the
          # base docker-entrypoint.sh with our args and the image sets no default
          # CMD. With no args the base entrypoint's "$1" != "postgres", so it
          # neither initializes nor starts the server and exits 0 immediately.
          # Supply "postgres" so it boots the server (and runs initdb.d/bootdb.d).
          args = ["postgres"]

          port {
            name           = "postgresql"
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-secrets"
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "TIMESCALEDB_TELEMETRY"
            value = "off"
          }

          # Per-app DB users/passwords consumed by the initdb.d scripts.
          dynamic "env" {
            for_each = toset(local.pg_app_env_keys)
            content {
              name = env.value
              value_from {
                secret_key_ref {
                  name = "postgres-secrets"
                  key  = env.value
                }
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/home/postgres/pgdata"
          }
          # Bin-place each file individually so the image's baked
          # /docker-entrypoint-initdb.d/0xx first-boot scripts are preserved.
          dynamic "volume_mount" {
            for_each = local.pg_initdb_files
            content {
              name       = "init-scripts"
              mount_path = "/docker-entrypoint-initdb.d/${volume_mount.key}"
              sub_path   = volume_mount.key
            }
          }

          resources {
            requests = { cpu = "250m", memory = "512Mi" }
            limits   = { cpu = "2", memory = "4Gi" }
          }

          liveness_probe {
            exec { command = ["sh", "-c", "pg_isready -U postgres"] }
            initial_delay_seconds = 45
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "pg_isready -U postgres"] }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.postgres.metadata[0].name
          }
        }
        volume {
          name = "init-scripts"
          config_map {
            name         = kubernetes_config_map_v1.postgres_init.metadata[0].name
            default_mode = "0755"
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "postgres" {
  metadata {
    name      = "infra-timescaledb"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "postgres" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "postgres" }
    port {
      name        = "postgresql"
      port        = 5432
      target_port = 5432
    }
  }
}
