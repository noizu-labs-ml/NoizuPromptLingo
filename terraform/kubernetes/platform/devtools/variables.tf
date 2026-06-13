variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Devtools-tier namespace (created by this module)."
  type        = string
  default     = "platform-devtools"
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

# --- code-server -----------------------------------------------------------
variable "code_server_image" {
  type    = string
  default = "lscr.io/linuxserver/code-server:latest"
}

variable "code_server_domain" {
  type    = string
  default = "code.noizu.com"
}

variable "code_server_storage" {
  type    = string
  default = "50Gi"
}

variable "code_server_tz" {
  type    = string
  default = "America/Chicago"
}

# --- livecodes -------------------------------------------------------------
variable "livecodes_image" {
  type    = string
  default = "ops.noizu.com/livecodes:latest"
}

variable "livecodes_domain" {
  type    = string
  default = "livecodes.noizu.com"
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
  default = "/devtools"
}

variable "managed_secret_name" {
  type    = string
  default = "devtools-app-secrets"
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
