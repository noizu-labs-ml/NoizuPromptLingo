# Mermaid Live Editor — text-to-diagram editor, served at mermaid.noizu.com.
# SvelteKit Node server with Authentik OIDC, shared Postgres (DSN in the secret),
# SendGrid email and OTEL log export. All secrets come from mermaid-secrets
# (/creative/mermaid) via envFrom; explicit env below sets non-secret config.
resource "kubernetes_deployment_v1" "mermaid" {
  metadata {
    name      = "mermaid"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mermaid" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "mermaid" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "mermaid" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "mermaid"
          image = var.mermaid_image
          port {
            container_port = 8080
            name           = "http"
          }

          # All Infisical-managed keys (DB DSN, OIDC client, SendGrid key, auth secret).
          env_from {
            secret_ref {
              name = "mermaid-secrets"
            }
          }

          env {
            name  = "ORIGIN"
            value = "https://${var.mermaid_domain}"
          }
          env {
            name  = "PORT"
            value = "8080"
          }
          env {
            name  = "HOST"
            value = "0.0.0.0"
          }
          env {
            name  = "XFF_DEPTH"
            value = "2"
          }
          env {
            name  = "BETTER_AUTH_URL"
            value = "https://${var.mermaid_domain}"
          }
          env {
            name  = "AUTHENTIK_ISSUER_URL"
            value = var.mermaid_authentik_issuer
          }
          env {
            name  = "SENDGRID_FROM_EMAIL"
            value = "noreply@noizu.com"
          }
          env {
            name  = "SENDGRID_FROM_NAME"
            value = "Mermaid Live Editor"
          }
          env {
            name  = "LOG_FORMAT"
            value = "jsonl"
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
          env {
            name  = "SERVICE_NAMESPACE"
            value = "creative"
          }
          env {
            name  = "OTEL_SERVICE_NAME"
            value = "mermaid"
          }
          env {
            name  = "OTEL_DEPLOYMENT_ENVIRONMENT"
            value = "prod"
          }
          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = var.mermaid_otel_endpoint
          }
          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = "service.name=mermaid,service.namespace=creative,deployment.environment=prod,k8s.namespace.name=${local.ns},k8s.deployment.name=mermaid"
          }

          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "768Mi" }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 15
            period_seconds        = 30
            timeout_seconds       = 3
            failure_threshold     = 3
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 2
          }
        }
      }
    }
  }
  depends_on = [
    kubectl_manifest.infisical_app,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_service_v1" "mermaid" {
  metadata {
    name      = "mermaid"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mermaid" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "mermaid" }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "mermaid" {
  metadata {
    name        = "mermaid-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "mermaid" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.mermaid_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.mermaid_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.mermaid.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
