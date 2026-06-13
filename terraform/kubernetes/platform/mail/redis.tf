# =============================================================================
# Redis (shared — rspamd + admin caching)
# =============================================================================
resource "kubernetes_deployment_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = local.ns
    labels    = local.labels["redis"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "redis" }
    }
    template {
      metadata {
        labels = { app = "redis" }
      }
      spec {
        security_context {
          fs_group = 999
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 999:999 /data"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        container {
          name    = "redis"
          image   = local.images.redis
          command = ["redis-server", "--appendonly", "yes", "--dir", "/data"]
          port {
            name           = "redis"
            container_port = 6379
          }
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.app_secret_name
                key  = "REDIS_PASSWORD"
              }
            }
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "1000m", memory = "2Gi" }
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          liveness_probe {
            exec { command = ["sh", "-c", "redis-cli ping | grep PONG"] }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "redis-cli ping | grep PONG"] }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.redis.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = local.ns
    labels    = local.labels["redis"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "redis" }
    port {
      name        = "redis"
      port        = 6379
      target_port = 6379
    }
  }
}
