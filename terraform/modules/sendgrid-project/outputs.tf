output "api_key_id" {
  description = "SendGrid API key ID (for import tracking)"
  value       = sendgrid_api_key.this.id
}

output "api_key" {
  description = "SendGrid API key value"
  value       = sendgrid_api_key.this.api_key
  sensitive   = true
}

output "domain_auth_id" {
  description = "SendGrid sender authentication ID"
  value       = sendgrid_sender_authentication.this.id
}

output "dkim_cnames" {
  description = "CNAME records needed for SendGrid DKIM domain authentication"
  value       = sendgrid_sender_authentication.this.dns
}
