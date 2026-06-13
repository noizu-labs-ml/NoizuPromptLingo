# PlantUML server — UML diagram renderer, served at plantuml.noizu.com. Stateless.
resource "kubernetes_deployment_v1" "plantuml" {
  metadata {
    name      = "plantuml"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "plantuml" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "plantuml" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "plantuml" }) }
      spec {
        node_selector = local.node_selector
        container {
          name  = "plantuml"
          image = var.plantuml_image
          port {
            container_port = 8080
            name           = "http"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "plantuml" {
  metadata {
    name      = "plantuml"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "plantuml" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "plantuml" }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "plantuml" {
  metadata {
    name        = "plantuml-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "plantuml" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.plantuml_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.plantuml_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.plantuml.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
