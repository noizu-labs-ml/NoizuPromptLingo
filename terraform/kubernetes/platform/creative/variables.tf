variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Creative-tier namespace (created by this module)."
  type        = string
  default     = "platform-creative"
}

variable "storage_class" {
  type    = string
  default = "longhorn"
}

variable "node_selector" {
  type    = map(string)
  default = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  type    = string
  default = ""
}

# --- Shared data tier (platform/init) --------------------------------------
variable "postgres_host" {
  type    = string
  default = "platform-timescaledb.platform.svc.cluster.local"
}

variable "valkey_host" {
  type    = string
  default = "platform-valkey.platform.svc.cluster.local"
}

# Apps that have a per-app Infisical secret at /creative/<app> -> <app>-secrets.
variable "app_secret_names" {
  type    = list(string)
  default = ["excalidraw", "mermaid", "penpot", "webstudio"]
}

# --- chartdb ---------------------------------------------------------------
variable "chartdb_image" {
  type    = string
  default = "ops.noizu.com/chartdb/chartdb:latest"
}
variable "chartdb_domain" {
  type    = string
  default = "chartdb.noizu.com"
}

# --- drawio ----------------------------------------------------------------
variable "drawio_image" {
  type    = string
  default = "jgraph/drawio:26.2.15"
}
variable "drawio_domain" {
  type    = string
  default = "drawio.noizu.com"
}

# --- plantuml --------------------------------------------------------------
variable "plantuml_image" {
  type    = string
  default = "plantuml/plantuml-server:jetty"
}
variable "plantuml_domain" {
  type    = string
  default = "plantuml.noizu.com"
}

# --- kroki -----------------------------------------------------------------
variable "kroki_image" {
  type    = string
  default = "yuzutech/kroki:0.26.0"
}
variable "kroki_mermaid_image" {
  type    = string
  default = "yuzutech/kroki-mermaid:0.26.0"
}
variable "kroki_bpmn_image" {
  type    = string
  default = "yuzutech/kroki-bpmn:0.26.0"
}
variable "kroki_excalidraw_image" {
  type    = string
  default = "yuzutech/kroki-excalidraw:0.26.0"
}
variable "kroki_diagramsnet_image" {
  type    = string
  default = "yuzutech/kroki-diagramsnet:0.26.0"
}
variable "kroki_domain" {
  type    = string
  default = "kroki.noizu.com"
}

# --- mydraft ---------------------------------------------------------------
variable "mydraft_image" {
  type    = string
  default = "ops.noizu.com/noizu/mydraft-server:latest"
}
variable "mydraft_domain" {
  type    = string
  default = "mydraft.noizu.com"
}
variable "mydraft_storage" {
  type    = string
  default = "5Gi"
}

# --- excalidraw ------------------------------------------------------------
variable "excalidraw_frontend_image" {
  type    = string
  default = "excalidraw/excalidraw:latest"
}
variable "excalidraw_room_image" {
  type    = string
  default = "excalidraw/excalidraw-room:latest"
}
variable "excalidraw_domain" {
  type    = string
  default = "excalidraw.noizu.com"
}
variable "excalidraw_redis_db" {
  type    = string
  default = "1"
}

# --- mermaid ---------------------------------------------------------------
variable "mermaid_image" {
  type    = string
  default = "ops.noizu.com/mermaid-live-editor:v20260601-oauth-fix.3"
}
variable "mermaid_domain" {
  type    = string
  default = "mermaid.noizu.com"
}
variable "mermaid_authentik_issuer" {
  type    = string
  default = "https://auth.derobot.is/application/o/mermaid"
}
variable "mermaid_otel_endpoint" {
  type    = string
  default = "http://otel-collector.observability-ns.svc.cluster.local:4318"
}

# --- penpot (deployed via helm_release of the vendored chart) --------------
variable "penpot_domain" {
  type    = string
  default = "penpot.noizu.com"
}
variable "penpot_minio_storage" {
  type    = string
  default = "100Gi"
}

# --- webstudio -------------------------------------------------------------
variable "webstudio_builder_image" {
  type    = string
  default = "ops.noizu.com/webstudio/builder:latest"
}
variable "webstudio_postgrest_image" {
  type    = string
  default = "postgrest/postgrest:v12.2.0"
}
variable "webstudio_domain" {
  type    = string
  default = "webstudio.noizu.com"
}
variable "webstudio_publisher_host" {
  type    = string
  default = "wstd.work"
}
variable "webstudio_db_name" {
  type    = string
  default = "webstudio"
}

# --- Infisical operator config ---------------------------------------------
variable "infisical_project_slug" {
  type    = string
  default = "k8-infra"
}
variable "infisical_env_slug" {
  type    = string
  default = "prod"
}
variable "infisical_credentials_secret" {
  type    = string
  default = "universal-auth-credentials"
}
variable "infisical_credentials_namespace" {
  type    = string
  default = "infra"
}
variable "infisical_resync_interval" {
  type    = number
  default = 120
}
# Self-hosted Infisical API. Without this the operator defaults to Infisical
# Cloud (app.infisical.com) and every InfisicalSecret 401s, so cloudflare-tls-synced
# never syncs and ingresses fall back to nginx's self-signed Fake Certificate.
variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
variable "tls_secret_name" {
  type    = string
  default = "cloudflare-tls-synced"
}
variable "registry_secrets_path" {
  type    = string
  default = "/shared/registry"
}
