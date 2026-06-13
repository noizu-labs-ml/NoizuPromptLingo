# ---------------------------------------------------------------------------
# Weaviate — upstream chart (weaviate/weaviate 17.8.0, appVersion 1.34.0).
# NPL memory vector store, vectorized by the self-hosted vLLM e5-mistral server.
# Deployed via helm_release. The wrapper added three out-of-band InfisicalSecret
# CRs and a standalone ingress (upstream has none) — all reproduced below.
# ---------------------------------------------------------------------------

# --- App secrets (raw key-value, consumed via envSecrets) ---
resource "kubectl_manifest" "weaviate_infisical" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-weaviate-secrets"
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
            secretsPath = "/ai/weaviate"
          }
        }
      }
      managedSecretReference = {
        secretName      = "weaviate-app-secrets"
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

# --- Image pull secret: ops.noizu.com private registry ---
resource "kubectl_manifest" "weaviate_ops_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-weaviate-ops-pull"
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
            secretsPath = "/ai/weaviate"
          }
        }
      }
      managedSecretReference = {
        secretName      = "ops-registry-secret"
        secretNamespace = local.ns
        secretType      = "kubernetes.io/dockerconfigjson"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            ".dockerconfigjson" = "{{ mustToJson (dict \"auths\" (dict \"ops.noizu.com\" (dict \"username\" .OPS_REGISTRY_USER.Value \"password\" .OPS_REGISTRY_PASSWORD.Value \"email\" \"keith.brings@noizu.com\" \"auth\" (printf \"%s:%s\" .OPS_REGISTRY_USER.Value .OPS_REGISTRY_PASSWORD.Value | b64enc)))) }}\n"
          }
        }
      }
    }
  })
  depends_on = [kubernetes_namespace_v1.ai]
}

# --- Image pull secret: Docker Hub ---
resource "kubectl_manifest" "weaviate_dockerhub_pull" {
  yaml_body = yamlencode({
    apiVersion = "secrets.infisical.com/v1alpha1"
    kind       = "InfisicalSecret"
    metadata = {
      name      = "infisical-weaviate-dockerhub-pull"
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
            secretsPath = "/ai/weaviate"
          }
        }
      }
      managedSecretReference = {
        secretName      = "docker-registry-secret"
        secretNamespace = local.ns
        secretType      = "kubernetes.io/dockerconfigjson"
        creationPolicy  = "Owner"
        template = {
          includeAllSecrets = false
          data = {
            ".dockerconfigjson" = "{{ mustToJson (dict \"auths\" (dict \"docker.io\" (dict \"username\" .DOCKERHUB_USER.Value \"password\" .DOCKERHUB_PASSWORD.Value \"email\" \"keith.brings@noizu.com\" \"auth\" (printf \"%s:%s\" .DOCKERHUB_USER.Value .DOCKERHUB_PASSWORD.Value | b64enc)))) }}\n"
          }
        }
      }
    }
  })
  depends_on = [kubernetes_namespace_v1.ai]
}

resource "helm_release" "weaviate" {
  name       = "weaviate"
  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"
  version    = "17.8.0"
  namespace  = local.ns

  values = [
    templatefile("${path.module}/files/weaviate/values.yaml.tftpl", {
      storage_class = local.storage_class
      namespace     = local.ns
    })
  ]

  depends_on = [
    kubectl_manifest.weaviate_infisical,
    kubectl_manifest.weaviate_ops_pull,
    kubectl_manifest.weaviate_dockerhub_pull,
  ]
}

# Standalone ingress (upstream weaviate chart ships none), Cloudflare-protected.
resource "kubernetes_ingress_v1" "weaviate" {
  metadata {
    name      = "weaviate"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "weaviate" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
      "nginx.ingress.kubernetes.io/auth-tls-verify-client" = "on"
      "nginx.ingress.kubernetes.io/auth-tls-secret"        = "${local.ns}/cloudflare-origin-pull-ca"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["weaviate.noizu.com"]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = "weaviate.noizu.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "weaviate"
              port { number = 80 }
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.weaviate]
}
