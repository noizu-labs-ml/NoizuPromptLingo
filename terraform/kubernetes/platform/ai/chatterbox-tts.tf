# ---------------------------------------------------------------------------
# Chatterbox TTS — OpenAI-compatible GPU text-to-speech, at chatterbox-tts.noizu.com.
# Requires an nvidia GPU node + runtimeClass "nvidia". Model cache + voices on PVCs.
# (ops-registry-secret is managed in this namespace by weaviate.tf.)
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "chatterbox_model_cache" {
  metadata {
    name      = "chatterbox-tts-model-cache"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
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

resource "kubernetes_persistent_volume_claim_v1" "chatterbox_voices" {
  metadata {
    name      = "chatterbox-tts-voices"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "1Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "chatterbox_tts" {
  metadata {
    name      = "chatterbox-tts"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "chatterbox-tts" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        runtime_class_name = "nvidia"
        container {
          name              = "chatterbox-tts"
          image             = var.chatterbox_image
          image_pull_policy = "Always"
          port {
            container_port = 4123
            protocol       = "TCP"
          }
          env {
            name  = "PORT"
            value = "4123"
          }
          env {
            name  = "DEVICE"
            value = "cuda"
          }
          volume_mount {
            name       = "model-cache"
            mount_path = "/root/.cache/huggingface"
          }
          volume_mount {
            name       = "voices"
            mount_path = "/app/voices"
          }
          resources {
            requests = {
              cpu              = "1"
              memory           = "4Gi"
              "nvidia.com/gpu" = "1"
            }
            limits = {
              cpu              = "8"
              memory           = "16Gi"
              "nvidia.com/gpu" = "1"
            }
          }
          # Allow up to ~20 min for first-run model download + GPU init.
          startup_probe {
            http_get {
              path = "/health"
              port = 4123
            }
            failure_threshold = 40
            period_seconds    = 30
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 4123
            }
            period_seconds    = 30
            failure_threshold = 3
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 4123
            }
            period_seconds = 10
          }
        }
        volume {
          name = "model-cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.chatterbox_model_cache.metadata[0].name
          }
        }
        volume {
          name = "voices"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.chatterbox_voices.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "chatterbox_tts" {
  metadata {
    name      = "chatterbox-tts"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
  }
  spec {
    type     = "ClusterIP"
    selector = { "app.kubernetes.io/name" = "chatterbox-tts" }
    port {
      port        = 4123
      target_port = 4123
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "chatterbox_tts" {
  metadata {
    name      = "chatterbox-tts-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "chatterbox-tts" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "50m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["chatterbox-tts.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "chatterbox-tts.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.chatterbox_tts.metadata[0].name
              port { number = 4123 }
            }
          }
        }
      }
    }
  }
}
