variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  type    = string
  default = "platform-tobor-locker"
}

variable "node_selector" {
  type    = map(string)
  default = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  type    = string
  default = ""
}

# --- Images ---
variable "elixir_image" {
  type    = string
  default = "ops.noizu.com/tobor-locker/elixir:v7"
}

variable "nextjs_image" {
  type    = string
  default = "ops.noizu.com/tobor-locker/nextjs:v3"
}

variable "nginx_image" {
  type    = string
  default = "ops.noizu.com/tobor-locker/nginx:v3"
}

variable "migrations_image" {
  type    = string
  default = "ops.noizu.com/tobor-locker/migrations:v3"
}

variable "domain" {
  type    = string
  default = "tobor.locker"
}

variable "tls_secret_name" {
  type    = string
  default = "toborlocker-tls"
}

# --- Infisical ---
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

variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}

variable "registry_secrets_path" {
  type    = string
  default = "/shared/registry"
}
