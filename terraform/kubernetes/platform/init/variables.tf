variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Platform-tier namespace."
  type        = string
  default     = "platform"
}

variable "storage_class" {
  description = "Fallback StorageClass if the root init state isn't readable."
  type        = string
  default     = "longhorn"
}

variable "node_selector" {
  description = "nodeSelector pinning workloads to the base node (fallback if init state isn't readable)."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  description = "Absolute path to the root init module's local tfstate. Set by Terragrunt (Terraform runs from a cache dir); empty falls back to the in-tree relative path for plain `terraform`."
  type        = string
  default     = ""
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
  description = "Universal-auth machine-identity credentials secret."
  type        = string
  default     = "universal-auth-credentials"
}

variable "infisical_credentials_namespace" {
  type    = string
  default = "infra"
}

variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}

variable "infisical_resync_interval" {
  type    = number
  default = 120
}
