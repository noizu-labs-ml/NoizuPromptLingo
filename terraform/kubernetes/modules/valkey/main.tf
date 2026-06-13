# ---------------------------------------------------------------------------
# Valkey instance with Infisical-managed credentials.
# ---------------------------------------------------------------------------
locals {
  labels = merge(var.labels, {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/component"  = "cache"
    "app.kubernetes.io/managed-by" = "terraform"
  })
  selector = { "app.kubernetes.io/name" = var.name }
}

# InfisicalSecret: operator syncs Infisical -> the managed Secret.
resource "kubectl_manifest" "infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-${var.name}"
      namespace = var.namespace
      labels    = local.labels
    }
    spec = {
      hostAPI        = var.infisical.host_api
      resyncInterval = var.infisical.resync_interval
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = var.infisical.credentials_secret
            secretNamespace = var.infisical.credentials_namespace
          }
          secretsScope = {
            projectSlug = var.infisical.project_slug
            envSlug     = var.infisical.env_slug
            secretsPath = var.infisical.secrets_path
          }
        }
      }
      managedSecretReference = {
        secretName      = var.managed_secret_name
        secretNamespace = var.namespace
        creationPolicy  = "Owner"
      }
    }
  })
}

resource "kubernetes_persistent_volume_claim_v1" "data" {
  metadata {
    name      = "${var.name}-data"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    resources {
      requests = { storage = var.storage_size }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "valkey" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = local.selector
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        node_selector = var.node_selector
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
          name    = "valkey"
          image   = var.image
          command = ["valkey-server", "--requirepass", "$(VALKEY_PASSWORD)", "--appendonly", "yes", "--dir", "/data"]

          port {
            name           = "valkey"
            container_port = 6379
          }

          env {
            name = "VALKEY_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = var.password_key
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          liveness_probe {
            exec { command = ["sh", "-c", "valkey-cli --no-auth-warning -a \"$VALKEY_PASSWORD\" ping | grep -q PONG"] }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            exec { command = ["sh", "-c", "valkey-cli --no-auth-warning -a \"$VALKEY_PASSWORD\" ping | grep -q PONG"] }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.data.metadata[0].name
          }
        }
      }
    }
  }

  # Managed Secret must be created by the operator first.
  depends_on = [kubectl_manifest.infisical]
}

resource "kubernetes_service_v1" "valkey" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector = local.selector
    port {
      name        = "valkey"
      port        = 6379
      target_port = 6379
    }
  }
}
