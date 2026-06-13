# =============================================================================
# PostgreSQL (shared — mailu + roundcube databases)
# =============================================================================
resource "kubernetes_deployment_v1" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = local.ns
    labels    = local.labels["postgresql"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "postgresql" }
    }
    template {
      metadata {
        labels = { app = "postgresql" }
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        security_context {
          fs_group = 70
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 70:70 /var/lib/postgresql/data"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        container {
          name  = "postgresql"
          image = local.images.postgresql
          port {
            name           = "postgresql"
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = var.postgres_user
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
          dynamic "env" {
            for_each = {
              POSTGRES_PASSWORD     = "POSTGRES_PASSWORD"
              MAILU_DB_USER         = "MAILU_DB_USER"
              MAILU_DB_PASSWORD     = "MAILU_DB_PASSWORD"
              ROUNDCUBE_DB_USER     = "ROUNDCUBE_DB_USER"
              ROUNDCUBE_DB_PASSWORD = "ROUNDCUBE_DB_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = local.app_secret_name
                  key  = env.value
                }
              }
            }
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }
          volume_mount {
            name       = "init-scripts"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          liveness_probe {
            exec { command = ["sh", "-c", "pg_isready -U $POSTGRES_USER"] }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "pg_isready -U $POSTGRES_USER"] }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.postgresql.metadata[0].name
          }
        }
        volume {
          name = "init-scripts"
          config_map {
            name         = kubernetes_config_map_v1.postgresql_init.metadata[0].name
            default_mode = "0755"
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = local.ns
    labels    = local.labels["postgresql"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "postgresql" }
    port {
      name        = "postgresql"
      port        = 5432
      target_port = 5432
    }
  }
}
