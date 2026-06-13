# ---------------------------------------------------------------------------
# Valkey — shared Redis-compatible cache/queue (per-app ACL users).
# ---------------------------------------------------------------------------
# Service name kept as "infra-valkey" so existing consumers resolve unchanged.
# ACL users + passwords are owned by the init module; we render them into an
# aclfile here. infra-services apps build their connection strings from the same
# init outputs, so usernames/passwords stay in sync.
locals {
  valkey_users = try(data.terraform_remote_state.init.outputs.shared_valkey_users, {})

  # One ACL line per user: full access to all keys/channels/commands.
  valkey_acl = join("\n", [
    for u, p in local.valkey_users : "user ${u} on >${p} ~* &* +@all"
  ])
}

# ACL file + default-user password (for the health probes), as a Secret.
resource "kubernetes_secret_v1" "valkey_acl" {
  metadata {
    name      = "infra-valkey-acl"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "valkey" })
  }
  type = "Opaque"
  data = {
    "users.acl"        = local.valkey_acl
    "default-password" = lookup(local.valkey_users, "default", "")
  }
}

resource "kubernetes_persistent_volume_claim_v1" "valkey" {
  metadata {
    name      = "infra-valkey-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "valkey" })
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

resource "kubernetes_deployment_v1" "valkey" {
  metadata {
    name      = "infra-valkey"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "valkey" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "valkey" }
    }
    template {
      metadata {
        # Roll the pod when the ACL changes.
        annotations = {
          "checksum/acl" = sha256(local.valkey_acl)
        }
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "valkey" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 999
        }
        # Copy the aclfile to a writable path (Valkey may rewrite it) and fix perms.
        init_container {
          name    = "prepare"
          image   = "busybox:1.36"
          command = ["sh", "-c", "cp /acl/users.acl /data/users.acl && chown -R 999:999 /data"]
          security_context {
            run_as_user = 0
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          volume_mount {
            name       = "acl"
            mount_path = "/acl"
          }
        }
        container {
          name    = "valkey"
          image   = "valkey/valkey:8.1-alpine"
          command = ["valkey-server", "--aclfile", "/data/users.acl", "--appendonly", "yes", "--dir", "/data"]

          port {
            container_port = 6379
            name           = "valkey"
          }

          # For the health probes (authenticate as the default user).
          env {
            name = "VALKEY_DEFAULT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.valkey_acl.metadata[0].name
                key  = "default-password"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }

          liveness_probe {
            exec { command = ["sh", "-c", "valkey-cli --no-auth-warning -a \"$VALKEY_DEFAULT_PASSWORD\" ping | grep -q PONG"] }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "valkey-cli --no-auth-warning -a \"$VALKEY_DEFAULT_PASSWORD\" ping | grep -q PONG"] }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.valkey.metadata[0].name
          }
        }
        volume {
          name = "acl"
          secret {
            secret_name = kubernetes_secret_v1.valkey_acl.metadata[0].name
            items {
              key  = "users.acl"
              path = "users.acl"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "valkey" {
  metadata {
    name      = "infra-valkey"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "valkey" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "valkey" }
    port {
      name        = "valkey"
      port        = 6379
      target_port = 6379
    }
  }
}
