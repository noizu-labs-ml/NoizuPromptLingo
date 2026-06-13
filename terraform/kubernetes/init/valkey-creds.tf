# ---------------------------------------------------------------------------
# Shared Valkey ACL credentials (source of truth)
# ---------------------------------------------------------------------------
# The shared Valkey (deployed by the infra module) authenticates per-app ACL
# users. Their passwords are generated here so init is the single source of
# truth; the infra module renders the ACL file from these, and infra-services
# apps build their connection strings from them — both via remote state.
#
# "default" is the admin user; the rest are per-app users.
variable "valkey_users" {
  description = "Per-app Valkey ACL usernames (in addition to the default user)."
  type        = list(string)
  default     = ["posthog", "authentik", "infisical"]
}

resource "random_password" "valkey" {
  for_each = toset(concat(["default"], var.valkey_users))

  length  = 32
  special = false # keep passwords safe in redis:// URLs and ACL files
}

output "shared_valkey_users" {
  description = "Map of Valkey ACL username => password for the shared Valkey."
  value       = { for u, r in random_password.valkey : u => r.result }
  sensitive   = true
}
