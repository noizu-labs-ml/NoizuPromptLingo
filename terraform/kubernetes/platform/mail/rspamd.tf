# =============================================================================
# Rspamd (antispam)
# =============================================================================
resource "kubernetes_deployment_v1" "rspamd" {
  metadata {
    name      = "rspamd"
    namespace = local.ns
    labels    = local.labels["rspamd"]
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "rspamd" }
    }
    template {
      metadata {
        labels = { app = "rspamd" }
      }
      spec {
        container {
          name  = "rspamd"
          image = local.images.rspamd
          port {
            name           = "proxy"
            container_port = 11332
          }
          port {
            name           = "controller"
            container_port = 11334
          }

          dynamic "env" {
            for_each = local.common_env_values
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.common_env_secrets
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
          dynamic "env" {
            for_each = local.service_env_values
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }

          volume_mount {
            name       = "dkim"
            mount_path = "/dkim"
            read_only  = true
          }
          volume_mount {
            name       = "filter-data"
            mount_path = "/var/lib/rspamd"
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = 11334
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/ping"
              port = 11334
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }

        volume {
          name = "dkim"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.dkim.metadata[0].name
          }
        }
        volume {
          name = "filter-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.filter.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "rspamd" {
  metadata {
    name      = "rspamd"
    namespace = local.ns
    labels    = local.labels["rspamd"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "rspamd" }
    port {
      name        = "proxy"
      port        = 11332
      target_port = 11332
    }
    port {
      name        = "controller"
      port        = 11334
      target_port = 11334
    }
  }
}
