# ---------------------------------------------------------------------------
# Kimai (time tracking) + its dedicated MariaDB. Both consume credentials from
# the Infisical-managed accounting-app-secrets Secret.
# ---------------------------------------------------------------------------

resource "kubernetes_persistent_volume_claim_v1" "kimai_data" {
  metadata {
    name      = "${var.release_name}-kimai-data"
    namespace = var.namespace
    labels    = { app = "kimai" }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.kimai_storage }
    }
  }
  wait_until_bound = false

  depends_on = [kubernetes_namespace_v1.accounting]
}

resource "kubernetes_persistent_volume_claim_v1" "kimai_mariadb_data" {
  metadata {
    name      = "${var.release_name}-kimai-mariadb-data"
    namespace = var.namespace
    labels    = { app = "kimai-mariadb" }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.kimai_mariadb_storage }
    }
  }
  wait_until_bound = false

  depends_on = [kubernetes_namespace_v1.accounting]
}

# --- Kimai MariaDB ---------------------------------------------------------
resource "kubernetes_deployment_v1" "kimai_mariadb" {
  metadata {
    name      = "kimai-mariadb"
    namespace = var.namespace
    labels    = { app = "kimai-mariadb" }
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "kimai-mariadb" }
    }
    template {
      metadata {
        labels = { app = "kimai-mariadb" }
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        security_context {
          fs_group = 999
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 999:999 /var/lib/mysql"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/mysql"
          }
        }
        container {
          name  = "mariadb"
          image = var.kimai_mariadb_image
          port {
            container_port = 3306
            name           = "mariadb"
          }
          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_MARIADB_ROOT_PASSWORD"
              }
            }
          }
          env {
            name  = "MARIADB_DATABASE"
            value = "kimai"
          }
          env {
            name  = "MARIADB_USER"
            value = "kimai"
          }
          env {
            name = "MARIADB_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_DATABASE_PASSWORD"
              }
            }
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/mysql"
          }
          liveness_probe {
            exec { command = ["mysqladmin", "ping", "-h", "localhost"] }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            exec { command = ["mysqladmin", "ping", "-h", "localhost"] }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.kimai_mariadb_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "kimai_mariadb" {
  metadata {
    name      = "kimai-mariadb"
    namespace = var.namespace
    labels    = { app = "kimai-mariadb" }
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "kimai-mariadb" }
    port {
      name        = "mariadb"
      port        = 3306
      target_port = 3306
    }
  }
}

# --- Kimai -----------------------------------------------------------------
resource "kubernetes_deployment_v1" "kimai" {
  metadata {
    name      = "kimai"
    namespace = var.namespace
    labels    = { app = "kimai" }
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "kimai" }
    }
    template {
      metadata {
        labels = { app = "kimai" }
      }
      spec {
        security_context {
          fs_group = 33
        }
        init_container {
          name    = "wait-for-db"
          image   = "busybox:latest"
          command = ["sh", "-c", "until nc -z kimai-mariadb 3306; do echo \"waiting for kimai-mariadb...\"; sleep 2; done"]
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 33:33 /opt/kimai/var"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/opt/kimai/var"
          }
        }
        container {
          name  = "kimai"
          image = var.kimai_image
          port {
            container_port = 8001
            name           = "http"
          }
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_DATABASE_URL"
              }
            }
          }
          env {
            name = "APP_SECRET"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_APP_SECRET"
              }
            }
          }
          env {
            name = "ADMINMAIL"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_ADMIN_EMAIL"
              }
            }
          }
          env {
            name = "ADMINPASS"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "KIMAI_ADMIN_PASSWORD"
              }
            }
          }
          env {
            name  = "TRUSTED_PROXIES"
            value = "0.0.0.0/0"
          }
          env {
            name  = "MAILER_URL"
            value = "null://null"
          }
          env {
            name = "MAILER_FROM"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "SMTP_FROM"
              }
            }
          }
          resources {
            requests = { cpu = "200m", memory = "256Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          volume_mount {
            name       = "data"
            mount_path = "/opt/kimai/var"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8001
            }
            initial_delay_seconds = 120
            period_seconds        = 30
            timeout_seconds       = 10
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8001
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.kimai_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "kimai" {
  metadata {
    name      = "kimai"
    namespace = var.namespace
    labels    = { app = "kimai" }
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "kimai" }
    port {
      name        = "http"
      port        = 8001
      target_port = 8001
    }
  }
}
