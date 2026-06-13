output "app_id" {
  description = "Cloudflare Zero Trust application ID"
  value       = cloudflare_zero_trust_access_application.this.id
}

output "aud" {
  description = "Application AUD tag (used for identity provider integration)"
  value       = cloudflare_zero_trust_access_application.this.aud
}
