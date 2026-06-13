variable "kube_config_path" {
  description = "Path to the kubeconfig file."
  type        = string
}

variable "kube_context" {
  description = "kubeconfig context for the target cluster (the colo server + VM members)."
  type        = string
}

variable "namespace" {
  description = "Namespace for the platform workloads (created by the init module)."
  type        = string
  default     = "infra"
}

variable "storage_class" {
  description = "StorageClass for all persistent volumes."
  type        = string
  default     = "longhorn"
}

variable "node_selector" {
  description = "nodeSelector pinning workloads to the base node (fallback if init state isn't readable)."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  description = "Absolute path to init's local tfstate. Set by Terragrunt (Terraform runs from a cache dir); empty falls back to the in-tree relative path for plain `terraform`."
  type        = string
  default     = ""
}
