# ---------------------------------------------------------------------------
# Open WebUI — LLM chat UI (webui.noizu.com) + LiteLLM proxy (inference.noizu.com)
# + LM Studio host bridge. Hand-translated from local chart templates.
# The LiteLLM model_list was rendered from the chart's templating into
# files/open-webui/litellm-config.yaml and mounted via ConfigMap.
# PVC volumeName pin dropped (dynamic provisioning via storage_class).
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "open_webui_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-open-webui-secrets"
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
            secretsPath = "/ai/open-webui"
          }
        }
      }
      managedSecretReference = {
        secretName      = "open-webui-app-secrets"
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

# --- LiteLLM proxy config (rendered from chart values) ----------------------
resource "kubernetes_config_map_v1" "litellm" {
  metadata {
    name      = "litellm-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "litellm" })
  }
  data = {
    "config.yaml" = file("${path.module}/files/open-webui/litellm-config.yaml")
  }
}

# --- Open WebUI -------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "open_webui" {
  metadata {
    name      = "open-webui-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "open-webui" })
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

resource "kubernetes_deployment_v1" "open_webui" {
  metadata {
    name      = "open-webui"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "open-webui" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "open-webui" }
    }
    template {
      metadata {
        labels = { app = "open-webui" }
      }
      spec {
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name  = "open-webui"
          image = "ghcr.io/open-webui/open-webui:0.9.6"

          port {
            container_port = 8080
          }

          env_from {
            secret_ref {
              name = "open-webui-app-secrets"
            }
          }

          # Open WebUI talks to LiteLLM with the master key (the real
          # OPENAI_API_KEY from envFrom is for LiteLLM's upstream, not WebUI).
          env {
            name = "OPENAI_API_KEY"
            value_from {
              secret_key_ref {
                name = "open-webui-app-secrets"
                key  = "LITELLM_MASTER_KEY"
              }
            }
          }
          env {
            name  = "OPENAI_API_KEYS"
            value = "$(OPENAI_API_KEY);lm-studio"
          }

          dynamic "env" {
            for_each = {
              OPENAI_API_BASE_URL  = "http://litellm:4000/v1"
              OPENAI_API_BASE_URLS = "http://litellm:4000/v1;http://lmstudio-proxy:3713/v1"
              WEBUI_AUTH           = "true"
              WEBUI_NAME           = "Noizu AI"
              DEFAULT_MODELS       = "zai/glm-5.1 (sub)"
              WEBUI_URL            = "https://webui.noizu.com"
              ENABLE_OAUTH_SIGNUP  = "true"
              DEFAULT_USER_ROLE    = "pending"
              ENABLE_OLLAMA_API    = "false"
              WEAVIATE_GRPC_PORT   = "50051"
            }
            content {
              name  = env.key
              value = env.value
            }
          }

          volume_mount {
            name       = "open-webui-data"
            mount_path = "/app/backend/data"
          }

          resources {
            requests = { memory = "1024Mi", cpu = "2000m" }
            limits   = { memory = "5Gi", cpu = "4000m" }
          }
        }
        volume {
          name = "open-webui-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.open_webui.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.open_webui_infisical]
}

resource "kubernetes_service_v1" "open_webui" {
  metadata {
    name      = "open-webui"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "open-webui" })
  }
  spec {
    selector = { app = "open-webui" }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

# --- LiteLLM proxy ----------------------------------------------------------
resource "kubernetes_deployment_v1" "litellm" {
  metadata {
    name      = "litellm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "litellm" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "litellm" }
    }
    template {
      metadata {
        labels = { app = "litellm" }
        annotations = {
          "checksum/config" = sha256(file("${path.module}/files/open-webui/litellm-config.yaml"))
        }
      }
      spec {
        container {
          name  = "litellm"
          image = "ghcr.io/berriai/litellm:main-v1.83.7-stable"
          args  = ["--config", "/app/config.yaml"]

          port {
            container_port = 4000
          }

          env_from {
            secret_ref {
              name = "open-webui-app-secrets"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config.yaml"
            sub_path   = "config.yaml"
          }

          resources {
            requests = { memory = "256Mi", cpu = "100m" }
            limits   = { memory = "1Gi", cpu = "1000m" }
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.litellm.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.open_webui_infisical]
}

resource "kubernetes_service_v1" "litellm" {
  metadata {
    name      = "litellm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "litellm" })
  }
  spec {
    selector = { app = "litellm" }
    port {
      port        = 4000
      target_port = 4000
    }
  }
}

# --- LM Studio host bridge (socat over hostNetwork) -------------------------
resource "kubernetes_deployment_v1" "lmstudio_proxy" {
  metadata {
    name      = "lmstudio-proxy"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "lmstudio-proxy" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "lmstudio-proxy" }
    }
    template {
      metadata {
        labels = { app = "lmstudio-proxy" }
      }
      spec {
        node_name    = "noizu-server"
        host_network = true
        dns_policy   = "ClusterFirstWithHostNet"
        container {
          name  = "proxy"
          image = "alpine/socat:1.8.0.3"
          args = [
            "-d",
            "-d",
            "TCP-LISTEN:3714,fork,reuseaddr",
            "TCP:127.0.0.1:3713",
          ]
          port {
            container_port = 3714
          }
          resources {
            requests = { memory = "32Mi", cpu = "10m" }
            limits   = { memory = "128Mi", cpu = "100m" }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "lmstudio_proxy" {
  metadata {
    name      = "lmstudio-proxy"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "lmstudio-proxy" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "lmstudio-proxy" }
    port {
      port        = 3713
      target_port = 3714
    }
  }
}

# --- Ingresses --------------------------------------------------------------
resource "kubernetes_ingress_v1" "open_webui" {
  metadata {
    name      = "open-webui"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "open-webui" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
      "nginx.ingress.kubernetes.io/auth-tls-verify-client" = "on"
      "nginx.ingress.kubernetes.io/auth-tls-secret"        = "${local.ns}/cloudflare-tls-synced"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["webui.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "webui.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.open_webui.metadata[0].name
              port { number = 8080 }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "litellm" {
  metadata {
    name      = "litellm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "litellm" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "3600"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["inference.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "inference.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.litellm.metadata[0].name
              port { number = 4000 }
            }
          }
        }
      }
    }
  }
}
