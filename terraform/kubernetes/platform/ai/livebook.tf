# ---------------------------------------------------------------------------
# Livebook — Elixir interactive notebooks, served at nb.noizu.com.
# Hand-translated from local chart templates. WebSocket-aware ingress.
# NOTE: the chart pinned the PVC to a specific pre-existing PV (volumeName);
# that pin is dropped here in favour of dynamic provisioning via storage_class.
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "livebook_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-livebook-secrets"
      namespace = local.ns
      labels    = local.common_labels
    }
    spec = {
      resyncInterval = local.infisical_base.resync_interval
      hostAPI        = local.infisical_base.host_api
      authentication = {
        universalAuth = {
          credentialsRef = {
            secretName      = local.infisical_base.credentials_secret
            secretNamespace = local.infisical_base.credentials_namespace
          }
          secretsScope = {
            projectSlug = local.infisical_base.project_slug
            envSlug     = local.infisical_base.env_slug
            secretsPath = "/ai/livebook"
          }
        }
      }
      managedSecretReference = {
        secretName      = "livebook-app-secrets"
        secretNamespace = local.ns
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = true
        }
      }
    }
  })
  depends_on = [kubernetes_namespace_v1.ai]
}

resource "kubernetes_persistent_volume_claim_v1" "livebook" {
  metadata {
    name      = "livebook-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livebook" })
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

resource "kubernetes_deployment_v1" "livebook" {
  metadata {
    name      = "livebook"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livebook" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "livebook" }
    }
    template {
      metadata {
        labels = { app = "livebook" }
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        # Run as root so writes under /data succeed regardless of image uid.
        security_context {
          run_as_user  = 0
          run_as_group = 0
          fs_group     = 0
        }
        init_container {
          name    = "seed-dirs"
          image   = "busybox:1.37"
          command = ["sh", "-c", "set -eux\nmkdir -p /data/home /data/notebooks /data/app-data /data/.mix-installs\nchmod 0755 /data /data/home /data/notebooks /data/app-data /data/.mix-installs\n"]
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        container {
          name  = "livebook"
          image = "ghcr.io/livebook-dev/livebook:latest"

          # The Livebook image ships ONLY pre-gzipped static assets
          # (priv/static/**/*.gz, no uncompressed siblings). The cluster's
          # ingress-nginx forces `Accept-Encoding: identity` upstream (a global
          # proxy-set-header needed by MinIO; per-ingress override is ineffective
          # and snippets are disabled for CVE-2023-5044), so Plug.Static 404s
          # every /assets/* request (no gzip accepted -> looks for the missing
          # uncompressed file). Decompress the assets in place at startup so the
          # uncompressed files exist, then exec the image's normal entrypoint
          # (CMD ["/app/bin/server"]). Version-agnostic via the find path.
          command = ["/bin/sh", "-c", "find /app/lib -path '*/priv/static/*' -name '*.gz' 2>/dev/null | while IFS= read -r f; do gunzip -kf \"$f\" 2>/dev/null || true; done; exec /app/bin/server"]

          port {
            name           = "http"
            container_port = 8080
          }

          env_from {
            secret_ref {
              name = "livebook-app-secrets"
            }
          }

          env {
            name  = "LIVEBOOK_IP"
            value = "0.0.0.0"
          }
          env {
            name  = "LIVEBOOK_PORT"
            value = "8080"
          }
          env {
            name  = "HOME"
            value = "/data/home"
          }
          env {
            name  = "LIVEBOOK_HOME"
            value = "/data/notebooks"
          }
          env {
            name  = "LIVEBOOK_DATA_PATH"
            value = "/data/app-data"
          }
          env {
            name  = "MIX_INSTALL_DIR"
            value = "/data/.mix-installs"
          }

          resources {
            requests = { cpu = "2000m", memory = "16Gi" }
            limits   = { cpu = "16000m", memory = "32Gi" }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          liveness_probe {
            http_get {
              path = "/public/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/public/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.livebook.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.livebook_infisical]
}

resource "kubernetes_service_v1" "livebook" {
  metadata {
    name      = "livebook"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livebook" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "livebook" }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "livebook" {
  metadata {
    name      = "livebook-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livebook" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "50m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "3600"
      "nginx.ingress.kubernetes.io/auth-tls-verify-client" = "on"
      "nginx.ingress.kubernetes.io/auth-tls-secret"        = "${local.ns}/cloudflare-tls-synced"
      "nginx.ingress.kubernetes.io/proxy-http-version"     = "1.1"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["nb.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "nb.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.livebook.metadata[0].name
              port { number = 8080 }
            }
          }
        }
      }
    }
  }
}
