# ---------------------------------------------------------------------------
# ZooKeeper — coordination for ClickHouse.
# ---------------------------------------------------------------------------
# Service name "infra-zookeeper" matches the host referenced in the ClickHouse
# cluster.xml config.
resource "kubernetes_persistent_volume_claim_v1" "zookeeper" {
  metadata {
    name      = "infra-zookeeper-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "zookeeper" })
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

resource "kubernetes_deployment_v1" "zookeeper" {
  metadata {
    name      = "infra-zookeeper"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "zookeeper" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "zookeeper" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "zookeeper" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          run_as_user = 0
        }
        container {
          name  = "zookeeper"
          image = "signoz/zookeeper:3.7.1"

          port {
            name           = "client"
            container_port = 2181
          }
          port {
            name           = "metrics"
            container_port = 9141
          }

          env {
            name  = "ZOO_SERVER_ID"
            value = "1"
          }
          env {
            name  = "ALLOW_ANONYMOUS_LOGIN"
            value = "yes"
          }
          env {
            name  = "ZOO_AUTOPURGE_INTERVAL"
            value = "1"
          }
          env {
            name  = "ZOO_ENABLE_PROMETHEUS_METRICS"
            value = "yes"
          }
          env {
            name  = "ZOO_PROMETHEUS_METRICS_PORT_NUMBER"
            value = "9141"
          }

          volume_mount {
            name       = "zookeeper-data"
            mount_path = "/bitnami/zookeeper"
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }

          liveness_probe {
            http_get {
              path = "/commands/ruok"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/commands/ruok"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "zookeeper-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.zookeeper.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "zookeeper" {
  metadata {
    name      = "infra-zookeeper"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "zookeeper" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "zookeeper" }
    port {
      name        = "client"
      port        = 2181
      target_port = 2181
    }
    port {
      name        = "metrics"
      port        = 9141
      target_port = 9141
    }
  }
}
