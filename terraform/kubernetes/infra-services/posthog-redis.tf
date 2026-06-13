# ---------------------------------------------------------------------------
# PostHog Redis — dedicated, passwordless (NOT the shared infra-valkey).
# ---------------------------------------------------------------------------
# PostHog's Node plugin-server (ioredis) issues single-arg `AUTH <password>` and
# cannot authenticate as a Valkey ACL *user* (username + password), so it fails
# against the shared infra-valkey (which requires the "posthog" ACL user). The
# known-good standalone PostHog deployment gives PostHog its own no-auth Redis;
# mirror that here. All PostHog components use redis://posthog-redis:6379/.
resource "kubernetes_persistent_volume_claim_v1" "posthog_redis" {
  metadata {
    name      = "posthog-redis-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-redis" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "5Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "posthog_redis" {
  metadata {
    name      = "posthog-redis"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-redis" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "posthog-redis" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-redis" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "redis"
          image = "redis:7-alpine"
          port {
            container_port = 6379
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
          liveness_probe {
            exec { command = ["redis-cli", "ping"] }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
          readiness_probe {
            exec { command = ["redis-cli", "ping"] }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.posthog_redis.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "posthog_redis" {
  metadata {
    name      = "posthog-redis"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-redis" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "posthog-redis" }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}
