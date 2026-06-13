variable "name" {
  description = "Workload/service name (e.g. platform-mongodb)."
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
  default     = "20Gi"
}

variable "image" {
  description = "MongoDB image."
  type        = string
  default     = "mongo:7"
}

variable "resources" {
  description = "Container resource requests/limits."
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = { cpu = "250m", memory = "512Mi" }
    limits   = { cpu = "2", memory = "4Gi" }
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

# --- Per-app DB provisioning -------------------------------------------------
# Same folder-name-is-source-of-truth convention as modules/mariadb. Each
# <app>/init-db.sh (sourcing _lib.sh) creates an app database + readWrite user.
# Folder name drives the <APP>_DB_USER / <APP>_DB_PASSWORD env keys.
variable "initdb_scripts_dir" {
  description = "Path to an initdb.d dir containing <app>/init-db.sh + _lib.sh. Empty disables per-app provisioning."
  type        = string
  default     = ""
}

variable "app_db_secret_name" {
  description = "Secret holding the per-app <APP>_DB_USER / <APP>_DB_PASSWORD keys. Empty falls back to managed_secret_name."
  type        = string
  default     = ""
}

# --- Infisical secret management -------------------------------------------
variable "managed_secret_name" {
  description = "Name of the Secret the Infisical operator creates."
  type        = string
}

variable "root_username_key" {
  description = "Key in the managed Secret holding the Mongo root username."
  type        = string
  default     = "MONGO_ROOT_USERNAME"
}

variable "password_key" {
  description = "Key in the managed Secret holding the Mongo root password."
  type        = string
  default     = "MONGO_ROOT_PASSWORD"
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
