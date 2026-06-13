# ---------------------------------------------------------------------------
# SigNoz — observability UI/backend, served at apm.noizu.com.
# ---------------------------------------------------------------------------
# Moved here from the infra (data-tier) module. Talks to infra-clickhouse,
# which lives in the same `infra` namespace (deployed by the infra module).
locals {
  signoz_host = "apm.noizu.com"
}

resource "kubernetes_config_map_v1" "signoz" {
  metadata {
    name      = "signoz-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
  }
  data = {
    "prometheus.yml" = file("${path.module}/files/signoz/prometheus.yml")
  }
}

resource "kubernetes_persistent_volume_claim_v1" "signoz" {
  metadata {
    name      = "signoz-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "25Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "signoz" {
  metadata {
    name      = "signoz"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "signoz" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
      }
      spec {
        node_selector = local.node_selector
        init_container {
          name    = "wait-for-clickhouse"
          image   = "busybox:1.36"
          command = ["sh", "-c", "echo 'Waiting for ClickHouse HTTP endpoint...'; until wget -q --spider http://infra-clickhouse.${local.ns}.svc.cluster.local:8123/ping 2>/dev/null; do echo 'ClickHouse not ready, waiting...'; sleep 5; done; echo 'ClickHouse is ready'"]
        }
        container {
          name  = "signoz"
          image = "signoz/signoz:v0.104.0"
          args  = ["--config=/root/config/prometheus.yml"]

          port {
            name           = "http"
            container_port = 8080
          }

          env {
            name  = "SIGNOZ_ALERTMANAGER_PROVIDER"
            value = "signoz"
          }
          env {
            name  = "SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN"
            value = "tcp://infra-clickhouse.${local.ns}.svc.cluster.local:9000"
          }
          env {
            name  = "SIGNOZ_SQLSTORE_SQLITE_PATH"
            value = "/var/lib/signoz/signoz.db"
          }
          env {
            name  = "DASHBOARDS_PATH"
            value = "/root/config/dashboards"
          }
          env {
            name  = "STORAGE"
            value = "clickhouse"
          }
          env {
            name  = "GODEBUG"
            value = "netdns=go"
          }
          env {
            name  = "TELEMETRY_ENABLED"
            value = "true"
          }
          env {
            name  = "DEPLOYMENT_TYPE"
            value = "kubernetes"
          }
          env {
            name  = "DOT_METRICS_ENABLED"
            value = "true"
          }
          env {
            name = "SIGNOZ_TOKENIZER_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "signoz-secrets"
                key  = "SIGNOZ_TOKENIZER_JWT_SECRET"
              }
            }
          }

          volume_mount {
            name       = "signoz-data"
            mount_path = "/var/lib/signoz"
          }
          volume_mount {
            name       = "signoz-config"
            mount_path = "/root/config"
          }

          resources {
            requests = { cpu = "500m", memory = "1Gi" }
            limits   = { cpu = "2", memory = "2Gi" }
          }

          liveness_probe {
            http_get {
              path = "/api/v1/health"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/api/v1/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "signoz-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.signoz.metadata[0].name
          }
        }
        volume {
          name = "signoz-config"
          config_map {
            name = kubernetes_config_map_v1.signoz.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "signoz" {
  metadata {
    name      = "signoz"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "signoz" }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "signoz" {
  metadata {
    name      = "signoz-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "signoz" })
    # NOTE: no `configuration-snippet` annotation here. The ingress-nginx admission
    # webhook rejects snippet directives (disabled cluster-wide — the secure default
    # since ingress-nginx v1.9); including one silently blocks the whole Ingress from
    # being admitted, so apm.noizu.com ends up with no ingress and no TLS at all. The
    # snippet only set static-asset Cache-Control headers (a UI nicety); dropped.
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"         = "true"
      "nginx.ingress.kubernetes.io/enable-websocket"     = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"      = "100m"
      "nginx.ingress.kubernetes.io/proxy-buffering"      = "on"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"    = "128k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "8"
      "nginx.ingress.kubernetes.io/proxy-http-version"   = "1.1"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"   = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"   = "300"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.signoz_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.signoz_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.signoz.metadata[0].name
              port { number = 8080 }
            }
          }
        }
      }
    }
  }
}
