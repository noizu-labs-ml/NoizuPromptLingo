# ---------------------------------------------------------------------------
# MongoDB with Infisical-managed credentials + per-app DB provisioning.
# ---------------------------------------------------------------------------
# Mirrors modules/mariadb: a single-replica MongoDB whose root credentials are
# synced from Infisical. Setting MONGO_INITDB_ROOT_* enables authentication; the
# initdb.d/<app>/init-db.sh scripts create per-app databases + readWrite users.
# Data lives at /data/db (uid/gid 999, mongodb).
locals {
  labels = merge(var.labels, {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/component"  = "database"
    "app.kubernetes.io/managed-by" = "terraform"
  })
  selector = { "app.kubernetes.io/name" = var.name }

  app_scripts   = var.initdb_scripts_dir == "" ? [] : sort(tolist(fileset(var.initdb_scripts_dir, "*/init-db.sh")))
  app_dbs       = [for f in local.app_scripts : upper(dirname(f))]
  app_env_keys  = flatten([for a in local.app_dbs : ["${a}_DB_USER", "${a}_DB_PASSWORD"]])
  app_db_secret = var.app_db_secret_name != "" ? var.app_db_secret_name : var.managed_secret_name

  lib_file = (length(local.app_scripts) > 0 && fileexists("${var.initdb_scripts_dir}/_lib.sh")) ? {
    "_lib" = file("${var.initdb_scripts_dir}/_lib.sh")
  } : {}
  app_files = {
    for i, f in local.app_scripts :
    format("1%02d-%s.sh", i, dirname(f)) => file("${var.initdb_scripts_dir}/${f}")
  }
  initdb_files = merge(local.lib_file, local.app_files)
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
  count = length(local.initdb_files) > 0 ? 1 : 0
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

resource "kubernetes_deployment_v1" "mongodb" {
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
          fs_group     = 999
          run_as_user  = 999
          run_as_group = 999
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 999:999 /data/db"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/data/db"
          }
        }
        container {
          name  = "mongodb"
          image = var.image

          port {
            name           = "mongodb"
            container_port = 27017
          }

          env {
            name = "MONGO_INITDB_ROOT_USERNAME"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = var.root_username_key
              }
            }
          }
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = var.password_key
              }
            }
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
            mount_path = "/data/db"
          }
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
            exec { command = ["sh", "-c", "mongosh --quiet --eval 'db.adminCommand(\"ping\").ok' | grep -q 1"] }
            initial_delay_seconds = 45
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "mongosh --quiet --eval 'db.adminCommand(\"ping\").ok' | grep -q 1"] }
            initial_delay_seconds = 15
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
        dynamic "volume" {
          for_each = length(local.initdb_files) > 0 ? [1] : []
          content {
            name = "init"
            config_map {
              name         = kubernetes_config_map_v1.init[0].metadata[0].name
              default_mode = "0755"
            }
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

resource "kubernetes_service_v1" "mongodb" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector = local.selector
    port {
      name        = "mongodb"
      port        = 27017
      target_port = 27017
    }
  }
}
