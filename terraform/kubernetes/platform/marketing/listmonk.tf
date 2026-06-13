# ---------------------------------------------------------------------------
# Listmonk — newsletter / mailing-list manager, served at listmonk.noizu.com.
# Uses the shared Postgres (platform/init). An init container runs the idempotent
# --install / --upgrade before the server starts.
# ---------------------------------------------------------------------------
locals {
  listmonk_env = {
    LISTMONK_app__address = "0.0.0.0:9000"
    LISTMONK_db__host     = var.postgres_host
    LISTMONK_db__port     = "5432"
    LISTMONK_db__user     = var.listmonk_db_user
    LISTMONK_db__database = var.listmonk_db_name
    LISTMONK_db__ssl_mode = "disable"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "listmonk_data" {
  metadata {
    name      = "listmonk-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "listmonk" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.listmonk_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "listmonk" {
  metadata {
    name      = "listmonk"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "listmonk" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "listmonk" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "listmonk" })
      }
      spec {
        node_selector = local.node_selector

        init_container {
          name    = "db-wait"
          image   = "postgres:16-alpine"
          command = ["sh", "-c", "until pg_isready -h ${var.postgres_host} -p 5432 -U ${var.listmonk_db_user}; do echo 'waiting for postgres...'; sleep 3; done"]
        }
        init_container {
          name    = "listmonk-install"
          image   = var.listmonk_image
          command = ["sh", "-c", "./listmonk --install --idempotent --yes && ./listmonk --upgrade --yes"]
          dynamic "env" {
            for_each = local.listmonk_env
            content {
              name  = env.key
              value = env.value
            }
          }
          env {
            name = "LISTMONK_db__password"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "LISTMONK_DB_PASSWORD"
              }
            }
          }
        }

        container {
          name  = "listmonk"
          image = var.listmonk_image
          port {
            container_port = 9000
            protocol       = "TCP"
          }
          dynamic "env" {
            for_each = local.listmonk_env
            content {
              name  = env.key
              value = env.value
            }
          }
          env {
            name = "LISTMONK_db__password"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "LISTMONK_DB_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/listmonk/uploads"
            sub_path   = "uploads"
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "1000m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            failure_threshold     = 10
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 9000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            failure_threshold     = 5
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.listmonk_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "listmonk" {
  metadata {
    name      = "listmonk"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "listmonk" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "listmonk" }
    port {
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "listmonk" {
  metadata {
    name      = "listmonk-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "listmonk" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.listmonk_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.listmonk_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.listmonk.metadata[0].name
              port { number = 9000 }
            }
          }
        }
      }
    }
  }
}
