# ---------------------------------------------------------------------------
# Kitten TTS — lightweight CPU text-to-speech, at kitten-tts.noizu.com. Model
# cache on a PVC. (ops-registry-secret is managed in this namespace by weaviate.tf.)
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "kitten_model_cache" {
  metadata {
    name      = "kitten-tts-model-cache"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "kitten-tts" })
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

resource "kubernetes_deployment_v1" "kitten_tts" {
  metadata {
    name      = "kitten-tts"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "kitten-tts" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "kitten-tts" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "kitten-tts" })
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name              = "kitten-tts"
          image             = var.kitten_image
          image_pull_policy = "Always"
          port {
            container_port = 8005
            protocol       = "TCP"
          }
          volume_mount {
            name       = "model-cache"
            mount_path = "/root/.cache/huggingface"
          }
          resources {
            requests = { cpu = "1", memory = "1Gi" }
            limits   = { cpu = "8", memory = "4Gi" }
          }
          liveness_probe {
            http_get {
              path = "/docs"
              port = 8005
            }
            initial_delay_seconds = 30
            period_seconds        = 60
            failure_threshold     = 5
          }
          readiness_probe {
            http_get {
              path = "/docs"
              port = 8005
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
        volume {
          name = "model-cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.kitten_model_cache.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kitten_tts" {
  metadata {
    name      = "kitten-tts"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "kitten-tts" })
  }
  spec {
    type     = "ClusterIP"
    selector = { "app.kubernetes.io/name" = "kitten-tts" }
    port {
      port        = 8005
      target_port = 8005
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "kitten_tts" {
  metadata {
    name      = "kitten-tts-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "kitten-tts" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "50m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["kitten-tts.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "kitten-tts.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.kitten_tts.metadata[0].name
              port { number = 8005 }
            }
          }
        }
      }
    }
  }
}
