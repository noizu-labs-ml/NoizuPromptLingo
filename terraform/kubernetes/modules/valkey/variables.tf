variable "name" {
  description = "Workload/service name (e.g. platform-valkey)."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "storage_class" {
  description = "StorageClass for the data PVC."
  type        = string
}

variable "storage_size" {
  description = "Data volume size."
  type        = string
  default     = "5Gi"
}

variable "image" {
  description = "Valkey image."
  type        = string
  default     = "valkey/valkey:8.1-alpine"
}

variable "resources" {
  description = "Container resource requests/limits."
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = { cpu = "100m", memory = "256Mi" }
    limits   = { cpu = "500m", memory = "1Gi" }
  }
}

variable "labels" {
  description = "Extra labels applied to all resources."
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "nodeSelector pinning the pod to a node (e.g. the base node noizu-server). Empty = no constraint."
  type        = map(string)
  default     = {}
}

# --- Infisical secret management -------------------------------------------
# An InfisicalSecret CR syncs the Valkey password from Infisical into the
# managed Secret; the deployment reads VALKEY_PASSWORD from it.
variable "managed_secret_name" {
  description = "Name of the Secret the Infisical operator creates (consumed by the deployment)."
  type        = string
}

variable "password_key" {
  description = "Key in the managed Secret holding the Valkey password."
  type        = string
  default     = "VALKEY_PASSWORD"
}

variable "infisical" {
  description = "Infisical operator universalAuth config + secrets scope."
  type = object({
    host_api              = string
    project_slug          = string
    env_slug              = string
    secrets_path          = string
    credentials_secret    = string
    credentials_namespace = string
    resync_interval       = number
  })
}
