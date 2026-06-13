# Outputs consumed by the `../infra` module via terraform_remote_state, and
# handy for exporting backend credentials when bootstrapping infra.

output "namespace" {
  description = "Platform namespace created here and shared with the infra module."
  value       = kubernetes_namespace_v1.infra.metadata[0].name
}

output "storage_class" {
  description = "Default StorageClass for platform volumes."
  value       = "longhorn"
}

# Single source of truth for the node pin. Every downstream stack reads this and
# applies it as a nodeSelector so all workloads land on the base node
# (noizu-server) — the only node with the public IPs and the GPU, and where the
# single-replica Longhorn volumes live.
output "node_selector" {
  description = "nodeSelector pinning all platform workloads to the base node (noizu-server)."
  value       = var.minio_node_selector
}

output "minio_s3_endpoint" {
  description = "MinIO S3 API endpoint (the infra module's state backend)."
  value       = var.minio_s3_endpoint
}

output "minio_internal_endpoint" {
  description = "In-cluster MinIO S3 endpoint."
  value       = "http://${kubernetes_service_v1.minio.metadata[0].name}.${kubernetes_namespace_v1.infra.metadata[0].name}.svc.cluster.local:9000"
}

output "tfstate_bucket" {
  description = "Bucket holding downstream Terraform state."
  value       = var.tfstate_bucket
}

output "minio_root_user" {
  description = "MinIO root user (use as AWS_ACCESS_KEY_ID for the infra backend)."
  value       = var.minio_root_user
}

output "minio_root_password" {
  description = "MinIO root password (use as AWS_SECRET_ACCESS_KEY for the infra backend)."
  value       = var.minio_root_password
  sensitive   = true
}
