# ---------------------------------------------------------------------------
# PostHog — product analytics, served at posthog.noizu.com.
# ---------------------------------------------------------------------------
# Pointed at the SHARED data tier: infra-clickhouse, infra-timescaledb (DB URL in
# the secret), infra-valkey (Redis). Kafka is a dedicated Redpanda node
# (posthog-kafka) — there is no shared Kafka.
locals {
  posthog_host = "posthog.noizu.com"

  # Stable release, paired with ClickHouse 22.8 (posthog-clickhouse.tf): that CH
  # still allows the DEFAULT columns this image's Kafka-engine migration creates.
  # (master removed those DEFAULTs but assumes a PostHog-Cloud multi-cluster CH
  # topology — extra clusters/macros — so it's a poor fit for this single node.)
  posthog_image = "posthog/posthog:latest-release"

  # Plain (non-secret) env shared by web/worker/plugins. REDIS_URL points at
  # infra-valkey and interpolates VALKEY_USERNAME/VALKEY_PASSWORD (defined via
  # the secret-env block, emitted before this one so $(VAR) resolves).
  posthog_plain_env = {
    CLICKHOUSE_HOST                   = "posthog-clickhouse"
    CLICKHOUSE_DATABASE               = "posthog"
    CLICKHOUSE_SECURE                 = "false"
    CLICKHOUSE_VERIFY                 = "false"
    CLICKHOUSE_CLUSTER                = "posthog"
    CLICKHOUSE_REPLICATION            = "true"
    REDIS_URL                         = "redis://posthog-redis:6379/"
    KAFKA_HOSTS                       = "posthog-kafka:9092"
    KAFKA_URL                         = "kafka://posthog-kafka:9092"
    SITE_URL                          = "https://posthog.noizu.com"
    IS_BEHIND_PROXY                   = "true"
    TRUST_ALL_PROXIES                 = "true"
    DISABLE_SECURE_SSL_REDIRECT       = "true"
    SKIP_SERVICE_VERSION_REQUIREMENTS = "1"
  }

  # name => { secret, key }. VALKEY_USERNAME/PASSWORD come from the per-app
  # valkey credential secret (init-owned) and are referenced by REDIS_URL above.
  posthog_secret_env = {
    DATABASE_URL    = { secret = "posthog-secrets", key = "POSTHOG_DATABASE_URL" }
    SECRET_KEY      = { secret = "posthog-secrets", key = "POSTHOG_SECRET_KEY" }
    VALKEY_USERNAME = { secret = "posthog-valkey", key = "VALKEY_USERNAME" }
    VALKEY_PASSWORD = { secret = "posthog-valkey", key = "VALKEY_PASSWORD" }
  }

  # Wait-for-dependency init containers (point at the shared services).
  posthog_wait_inits = {
    wait-clickhouse = "until wget -q --spider http://posthog-clickhouse:8123/ping; do echo 'Waiting for ClickHouse...'; sleep 5; done"
    wait-postgres   = "until nc -z infra-timescaledb.${local.ns}.svc.cluster.local 5432; do echo 'Waiting for PostgreSQL...'; sleep 5; done"
    wait-redis      = "until nc -z infra-valkey 6379; do echo 'Waiting for Redis...'; sleep 5; done"
    wait-kafka      = "until nc -z posthog-kafka 9092; do echo 'Waiting for Kafka...'; sleep 5; done"
  }

  posthog_workers = {
    "posthog-worker"  = ["./bin/docker-worker-celery", "--with-scheduler"]
    "posthog-plugins" = ["./bin/plugin-server", "--no-restart-loop"]
  }

  # Per-worker extra env. The Node plugin-server auto-detects the host's CPU count
  # and spawns that many workers, OOMing on a big node — cap it (matches the
  # known-good standalone deployment's plugins env).
  posthog_worker_extra_env = {
    "posthog-plugins" = {
      WORKER_CONCURRENCY = "4"
      TASKS_PER_WORKER   = "10"
    }
  }
}

# --- Kafka (Redpanda) ------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "posthog_kafka" {
  metadata {
    name      = "posthog-kafka-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-kafka" })
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

resource "kubernetes_deployment_v1" "posthog_kafka" {
  metadata {
    name      = "posthog-kafka"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-kafka" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "posthog-kafka" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-kafka" })
      }
      spec {
        node_selector = local.node_selector
        security_context { fs_group = 101 }
        container {
          name  = "redpanda"
          image = "redpandadata/redpanda:v24.3.1"
          args = [
            "redpanda", "start", "--smp=1", "--memory=1G", "--reserve-memory=0M",
            "--overprovisioned", "--node-id=0",
            "--kafka-addr=PLAINTEXT://0.0.0.0:9092",
            "--advertise-kafka-addr=PLAINTEXT://posthog-kafka:9092",
            "--check=false",
          ]
          port {
            name           = "kafka"
            container_port = 9092
          }
          port {
            name           = "schema"
            container_port = 8081
          }
          port {
            name           = "admin"
            container_port = 9644
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/redpanda/data"
          }
          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "1", memory = "2Gi" }
          }
          liveness_probe {
            http_get {
              path = "/v1/status/ready"
              port = 9644
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 1
          }
          readiness_probe {
            http_get {
              path = "/v1/status/ready"
              port = 9644
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.posthog_kafka.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "posthog_kafka" {
  metadata {
    name      = "posthog-kafka"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-kafka" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "posthog-kafka" }
    port {
      name        = "kafka"
      port        = 9092
      target_port = 9092
    }
  }
}

# --- Web -------------------------------------------------------------------
resource "kubernetes_deployment_v1" "posthog_web" {
  metadata {
    name      = "posthog-web"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-web" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "posthog-web" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-web" })
      }
      spec {
        node_selector = local.node_selector
        dynamic "init_container" {
          for_each = local.posthog_wait_inits
          content {
            name    = init_container.key
            image   = "busybox:1.36"
            command = ["sh", "-c", init_container.value]
          }
        }
        init_container {
          name    = "migrate"
          image   = local.posthog_image
          command = ["sh", "-c", "python manage.py migrate --noinput && python manage.py migrate_clickhouse"]
          dynamic "env" {
            for_each = local.posthog_secret_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.secret
                  key  = env.value.key
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.posthog_plain_env
            content {
              name  = env.key
              value = env.value
            }
          }
        }
        container {
          name    = "posthog-web"
          image   = local.posthog_image
          command = ["./bin/docker-server"]

          port {
            container_port = 8000
          }

          dynamic "env" {
            for_each = local.posthog_secret_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.secret
                  key  = env.value.key
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.posthog_plain_env
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = { cpu = "500m", memory = "1Gi" }
            limits   = { cpu = "2", memory = "4Gi" }
          }

          liveness_probe {
            http_get {
              path = "/_health"
              port = 8000
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
          }
          readiness_probe {
            http_get {
              path = "/_ready"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.sealed,
    kubernetes_deployment_v1.posthog_kafka,
    kubernetes_deployment_v1.posthog_clickhouse,
    kubernetes_secret_v1.valkey_user,
  ]
}

# --- Worker + Plugins (no ports, exec-less; share env with web) ------------
resource "kubernetes_deployment_v1" "posthog_worker" {
  for_each = local.posthog_workers

  metadata {
    name      = each.key
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = each.key })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = each.key }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = each.key })
      }
      spec {
        node_selector = local.node_selector
        dynamic "init_container" {
          for_each = local.posthog_wait_inits
          content {
            name    = init_container.key
            image   = "busybox:1.36"
            command = ["sh", "-c", init_container.value]
          }
        }
        container {
          name    = each.key
          image   = local.posthog_image
          command = each.value

          dynamic "env" {
            for_each = local.posthog_secret_env
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.secret
                  key  = env.value.key
                }
              }
            }
          }
          dynamic "env" {
            for_each = local.posthog_plain_env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = lookup(local.posthog_worker_extra_env, each.key, {})
            content {
              name  = env.key
              value = env.value
            }
          }

          # The celery worker spawns processes per CPU and needs more headroom than
          # the (concurrency-capped) plugin-server, mirroring the known-good deploy.
          resources {
            requests = { cpu = "500m", memory = each.key == "posthog-worker" ? "2Gi" : "1Gi" }
            limits   = { cpu = "2", memory = each.key == "posthog-worker" ? "8Gi" : "4Gi" }
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed, kubernetes_deployment_v1.posthog_web]
}

resource "kubernetes_service_v1" "posthog_web" {
  metadata {
    name      = "posthog-web"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog-web" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "posthog-web" }
    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_ingress_v1" "posthog" {
  metadata {
    name      = "posthog-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "posthog" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "20m"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.posthog_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.posthog_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.posthog_web.metadata[0].name
              port { number = 8000 }
            }
          }
        }
      }
    }
  }
}
