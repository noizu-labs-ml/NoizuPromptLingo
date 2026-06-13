# ---------------------------------------------------------------------------
# vLLM — GPU embedding server (intfloat/e5-mistral-7b-instruct), OpenAI-compat
# /v1/embeddings on :8000, internal ClusterIP only. Vectorizes for Weaviate.
# Hand-translated from local chart templates. Requires an nvidia GPU node +
# runtimeClass "nvidia". PVC volumeName pin dropped (dynamic provisioning).
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "vllm_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-vllm-secrets"
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
            secretsPath = "/ai/vllm"
          }
        }
      }
      managedSecretReference = {
        secretName      = "vllm-app-secrets"
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

resource "kubernetes_persistent_volume_claim_v1" "vllm" {
  metadata {
    name      = "vllm-model-cache"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "vllm" })
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

resource "kubernetes_deployment_v1" "vllm" {
  metadata {
    name      = "vllm"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "vllm" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "vllm" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "vllm" })
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        runtime_class_name = "nvidia"
        # Prevent K8s injecting VLLM_PORT=tcp://... which collides with vLLM's
        # own VLLM_PORT env var (expects an integer port number).
        enable_service_links = false
        container {
          name              = "vllm"
          image             = "vllm/vllm-openai:latest"
          image_pull_policy = "IfNotPresent"
          args = [
            "--model", "intfloat/e5-mistral-7b-instruct",
            "--runner", "pooling",
            "--dtype", "float16",
            "--max-model-len", "8192",
            "--port", "8000",
            "--quantization", "bitsandbytes",
            "--load-format", "bitsandbytes",
            "--enforce-eager",
          ]

          env {
            name  = "HF_HOME"
            value = "/root/.cache/huggingface"
          }
          env {
            name = "HF_TOKEN"
            value_from {
              secret_key_ref {
                name = "vllm-app-secrets"
                key  = "HF_TOKEN"
              }
            }
          }

          port {
            name           = "http"
            container_port = 8000
            protocol       = "TCP"
          }

          volume_mount {
            name       = "model-cache"
            mount_path = "/root/.cache/huggingface"
          }

          resources {
            requests = {
              cpu              = "2"
              memory           = "8Gi"
              "nvidia.com/gpu" = "1"
            }
            limits = {
              cpu              = "8"
              memory           = "24Gi"
              "nvidia.com/gpu" = "1"
            }
          }

          startup_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            failure_threshold = 240
            period_seconds    = 30
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
        }
        volume {
          name = "model-cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.vllm.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.vllm_infisical]
}

resource "kubernetes_service_v1" "vllm" {
  metadata {
    name      = "vllm"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "vllm" })
  }
  spec {
    type     = "ClusterIP"
    selector = { "app.kubernetes.io/name" = "vllm" }
    port {
      name        = "http"
      port        = 8000
      target_port = "http"
      protocol    = "TCP"
    }
  }
}
