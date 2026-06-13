# ---------------------------------------------------------------------------
# ClickHouse — columnar store backing SigNoz.
# ---------------------------------------------------------------------------
# Config (config.xml/users.xml/custom-function.xml/config.d/cluster.xml) is held
# in files/clickhouse/* and mounted via subPath. cluster.xml references
# "infra-clickhouse" and "infra-zookeeper" by short name (same namespace).
resource "kubernetes_config_map_v1" "clickhouse" {
  metadata {
    name      = "infra-clickhouse-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
  }
  data = {
    "config.xml"          = file("${path.module}/files/clickhouse/config.xml")
    "users.xml"           = file("${path.module}/files/clickhouse/users.xml")
    "custom-function.xml" = file("${path.module}/files/clickhouse/custom-function.xml")
    "cluster.xml"         = file("${path.module}/files/clickhouse/cluster.xml")
  }
}

resource "kubernetes_persistent_volume_claim_v1" "clickhouse_data" {
  metadata {
    name      = "infra-clickhouse-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "50Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim_v1" "clickhouse_logs" {
  metadata {
    name      = "infra-clickhouse-logs"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "10Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "clickhouse" {
  metadata {
    name      = "infra-clickhouse"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "clickhouse" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 101
        }

        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 101:101 /var/lib/clickhouse /var/log/clickhouse-server"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "clickhouse-data"
            mount_path = "/var/lib/clickhouse"
          }
          volume_mount {
            name       = "clickhouse-logs"
            mount_path = "/var/log/clickhouse-server"
          }
        }

        init_container {
          name  = "init-histogram"
          image = "clickhouse/clickhouse-server:25.5.6"
          command = ["bash", "-c", <<-EOT
            if [ -x /var/lib/clickhouse/user_scripts/histogramQuantile ]; then
              echo "histogramQuantile already exists, skipping"
              exit 0
            fi
            version="v0.0.1"
            node_os=$(uname -s | tr '[:upper:]' '[:lower:]')
            node_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
            echo "Fetching histogram-quantile for $${node_os}/$${node_arch}"
            mkdir -p /var/lib/clickhouse/user_scripts
            cd /tmp
            wget -O histogram-quantile.tar.gz "https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2F$${version}/histogram-quantile_$${node_os}_$${node_arch}.tar.gz"
            tar -xvzf histogram-quantile.tar.gz
            mv histogram-quantile /var/lib/clickhouse/user_scripts/histogramQuantile
            chmod +x /var/lib/clickhouse/user_scripts/histogramQuantile
          EOT
          ]
          volume_mount {
            name       = "clickhouse-data"
            mount_path = "/var/lib/clickhouse"
          }
        }

        init_container {
          name    = "wait-for-zookeeper"
          image   = "busybox:1.36"
          command = ["sh", "-c", "until nc -z infra-zookeeper 2181; do echo 'waiting for zookeeper at infra-zookeeper:2181'; sleep 2; done"]
        }

        container {
          name  = "clickhouse"
          image = "clickhouse/clickhouse-server:25.5.6"

          port {
            name           = "native"
            container_port = 9000
          }
          port {
            name           = "http"
            container_port = 8123
          }
          port {
            name           = "metrics"
            container_port = 9363
          }

          env {
            name  = "CLICKHOUSE_SKIP_USER_SETUP"
            value = "1"
          }
          env {
            name = "SIGNOZ_TOKENIZER_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "clickhouse-secrets"
                key  = "SIGNOZ_TOKENIZER_JWT_SECRET"
              }
            }
          }

          volume_mount {
            name       = "clickhouse-data"
            mount_path = "/var/lib/clickhouse"
          }
          volume_mount {
            name       = "clickhouse-logs"
            mount_path = "/var/log/clickhouse-server"
          }
          volume_mount {
            name       = "clickhouse-config"
            mount_path = "/etc/clickhouse-server/config.xml"
            sub_path   = "config.xml"
          }
          volume_mount {
            name       = "clickhouse-config"
            mount_path = "/etc/clickhouse-server/users.xml"
            sub_path   = "users.xml"
          }
          volume_mount {
            name       = "clickhouse-config"
            mount_path = "/etc/clickhouse-server/custom-function.xml"
            sub_path   = "custom-function.xml"
          }
          volume_mount {
            name       = "clickhouse-config"
            mount_path = "/etc/clickhouse-server/config.d/cluster.xml"
            sub_path   = "cluster.xml"
          }

          resources {
            requests = { cpu = "500m", memory = "2Gi" }
            limits   = { cpu = "2", memory = "4Gi" }
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
          name = "clickhouse-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.clickhouse_data.metadata[0].name
          }
        }
        volume {
          name = "clickhouse-logs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.clickhouse_logs.metadata[0].name
          }
        }
        volume {
          name = "clickhouse-config"
          config_map {
            name = kubernetes_config_map_v1.clickhouse.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed, kubernetes_deployment_v1.zookeeper]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "clickhouse" {
  metadata {
    name      = "infra-clickhouse"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "clickhouse" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "clickhouse" }
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
    port {
      name        = "metrics"
      port        = 9363
      target_port = 9363
    }
  }
}
