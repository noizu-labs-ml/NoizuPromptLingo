# =============================================================================
# Terraform outputs — consumed by utils/ scripts and documented workflows
# =============================================================================
# Read via:
#   terraform -chdir=terraform-vnext/zero-trust output -raw <name>
# =============================================================================

output "cf_team_name" {
  value       = local.cf_team_name
  description = "Cloudflare Zero Trust team (subdomain of <team>.cloudflareaccess.com)"
}

output "livebook_aud" {
  value       = module.livebook.aud
  description = "AUD tag for Livebook's CF Access Application (nb.noizu.com)"
}

output "livebook_zta_provider_string" {
  value       = "cloudflare:${local.cf_team_name}:${module.livebook.aud}"
  description = "Composed value for LIVEBOOK_IDENTITY_PROVIDER env var"
}
