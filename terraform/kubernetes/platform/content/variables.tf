variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Content-tier namespace (created by this module)."
  type        = string
  default     = "platform-content"
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

variable "mariadb_host" {
  type    = string
  default = "platform-mariadb.platform.svc.cluster.local"
}

variable "valkey_host" {
  type    = string
  default = "platform-valkey.platform.svc.cluster.local"
}

# --- docmost ---------------------------------------------------------------
variable "docmost_image" {
  type    = string
  default = "docmost/docmost:latest"
}

variable "docmost_domain" {
  type    = string
  default = "docmost.noizu.com"
}

variable "docmost_storage" {
  type    = string
  default = "50Gi"
}

# --- ghost -----------------------------------------------------------------
variable "ghost_image" {
  type    = string
  default = "ghost:5.109-alpine"
}

variable "ghost_domain" {
  type    = string
  default = "ghost.noizu.com"
}

variable "ghost_db_name" {
  type    = string
  default = "ghost"
}

variable "ghost_db_user" {
  type    = string
  default = "ghost"
}

variable "ghost_storage" {
  type    = string
  default = "10Gi"
}

# --- nextcloud -------------------------------------------------------------
variable "nextcloud_image" {
  type    = string
  default = "nextcloud:29-apache"
}

variable "nextcloud_domain" {
  type    = string
  default = "nextcloud.noizu.com"
}

variable "nextcloud_db_name" {
  type    = string
  default = "nextcloud"
}

variable "nextcloud_storage" {
  type    = string
  default = "100Gi"
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

variable "infisical_secrets_path" {
  type    = string
  default = "/content"
}

variable "managed_secret_name" {
  type    = string
  default = "content-app-secrets"
}

variable "tls_secret_name" {
  type    = string
  default = "cloudflare-tls-synced"
}

variable "registry_secrets_path" {
  type    = string
  default = "/shared/registry"
}

# Self-hosted Infisical API. Without this the operator defaults to Infisical
# Cloud (app.infisical.com) and every InfisicalSecret 401s, so cloudflare-tls-synced
# never syncs and ingresses fall back to nginx's self-signed Fake Certificate.
variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
