variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Marketing-tier namespace (created by this module)."
  type        = string
  default     = "platform-marketing"
}

variable "storage_class" {
  description = "Fallback StorageClass if the root init state isn't readable."
  type        = string
  default     = "longhorn"
}

variable "node_selector" {
  description = "nodeSelector fallback if the root init state isn't readable."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  description = "Absolute path to the root init module's local tfstate (set by Terragrunt)."
  type        = string
  default     = ""
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

# --- listmonk --------------------------------------------------------------
variable "listmonk_image" {
  type    = string
  default = "listmonk/listmonk:latest"
}

variable "listmonk_domain" {
  type    = string
  default = "listmonk.noizu.com"
}

variable "listmonk_db_name" {
  type    = string
  default = "listmonk"
}

variable "listmonk_db_user" {
  type    = string
  default = "listmonk"
}

variable "listmonk_storage" {
  type    = string
  default = "5Gi"
}

# --- mautic ----------------------------------------------------------------
variable "mautic_image" {
  type    = string
  default = "mautic/mautic:5-apache"
}

variable "mautic_domain" {
  type    = string
  default = "mautic.noizu.com"
}

variable "mautic_db_name" {
  type    = string
  default = "mautic"
}

variable "mautic_db_user" {
  type    = string
  default = "mautic"
}

variable "mautic_storage" {
  type    = string
  default = "5Gi"
}

# --- Infisical operator config (shared across this tier's workloads) --------
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
  default = "/marketing"
}

variable "managed_secret_name" {
  type    = string
  default = "marketing-app-secrets"
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
