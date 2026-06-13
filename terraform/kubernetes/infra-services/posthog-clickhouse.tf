# ---------------------------------------------------------------------------
# PostHog ClickHouse + ZooKeeper — dedicated, pinned instances for PostHog only.
# ---------------------------------------------------------------------------
# PostHog's stable `latest-release` image defines its Kafka-engine tables with
# DEFAULT columns, which ClickHouse 23.3+ rejects ("KafkaEngine doesn't support
# DEFAULT … expressions"). PostHog is supported on ClickHouse 22.8 LTS, which
# still allows them, so it runs against this self-contained instance rather than
# the shared infra-clickhouse (25.x). Mirrors the known-good standalone PostHog
# deployment: cluster "posthog", a dedicated single-node ZooKeeper, and the pod
# hostname set to the service name so ON CLUSTER DDL runs locally.
locals {
  posthog_ch_image = "clickhouse/clickhouse-server:22.8.21.38"
  posthog_zk_image = "zookeeper:3.9"
}

# --- ZooKeeper (coordination for ClickHouse replicated tables) -------------
resource "kubernetes_deployment_v1" "posthog_zookeeper" {
  metadata {
    name      = "posthog-zookeeper"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-zookeeper" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "posthog-zookeeper" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-zookeeper" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "zookeeper"
          image = local.posthog_zk_image
          port {
            container_port = 2181
          }
          env {
            name  = "ZOO_4LW_COMMANDS_WHITELIST"
            value = "mntr,conf,ruok"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
          readiness_probe {
            exec { command = ["sh", "-c", "echo ruok | nc localhost 2181 | grep imok"] }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          liveness_probe {
            exec { command = ["sh", "-c", "echo ruok | nc localhost 2181 | grep imok"] }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        volume {
          name = "data"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "posthog_zookeeper" {
  metadata {
    name      = "posthog-zookeeper"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-zookeeper" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "posthog-zookeeper" }
    port {
      port        = 2181
      target_port = 2181
    }
  }
}

# --- ClickHouse ------------------------------------------------------------
resource "kubernetes_config_map_v1" "posthog_clickhouse" {
  metadata {
    name      = "posthog-clickhouse-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-clickhouse" })
  }
  data = {
    "config.xml" = file("${path.module}/files/posthog-clickhouse/config.xml")
    "users.xml"  = file("${path.module}/files/posthog-clickhouse/users.xml")
  }
}

resource "kubernetes_persistent_volume_claim_v1" "posthog_clickhouse" {
  metadata {
    name      = "posthog-clickhouse-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-clickhouse" })
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

resource "kubernetes_deployment_v1" "posthog_clickhouse" {
  metadata {
    name      = "posthog-clickhouse"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-clickhouse" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "posthog-clickhouse" }
    }
    template {
      metadata {
        annotations = {
          "checksum/config" = sha256(join("", [
            file("${path.module}/files/posthog-clickhouse/config.xml"),
            file("${path.module}/files/posthog-clickhouse/users.xml"),
          ]))
        }
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-clickhouse" })
      }
      spec {
        node_selector = local.node_selector
        # Hostname must match the cluster replica host (posthog-clickhouse) so the
        # node recognizes itself and ON CLUSTER DDL executes locally.
        hostname = "posthog-clickhouse"
        security_context {
          fs_group = 101
        }

        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 101:101 /var/lib/clickhouse"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/clickhouse"
          }
        }

        container {
          name  = "clickhouse"
          image = local.posthog_ch_image

          port {
            name           = "native"
            container_port = 9000
          }
          port {
            name           = "http"
            container_port = 8123
          }
          port {
            name           = "interserver"
            container_port = 9009
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/clickhouse"
          }
          # Overlays merged onto the image's stock config (defaults preserved).
          volume_mount {
            name       = "config"
            mount_path = "/etc/clickhouse-server/config.d/custom.xml"
            sub_path   = "config.xml"
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/clickhouse-server/users.d/custom-users.xml"
            sub_path   = "users.xml"
          }

          resources {
            requests = { cpu = "500m", memory = "2Gi" }
            limits   = { cpu = "4", memory = "8Gi" }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.posthog_clickhouse.metadata[0].name
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.posthog_clickhouse.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.posthog_zookeeper]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "posthog_clickhouse" {
  metadata {
    name      = "posthog-clickhouse"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-clickhouse" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "posthog-clickhouse" }
    port {
      name        = "native"
      port        = 9000
      target_port = 9000
    }
    port {
      name        = "http"
      port        = 8123
      target_port = 8123
    }
  }
}
