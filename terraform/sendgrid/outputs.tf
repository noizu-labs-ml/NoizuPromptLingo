output "infra_api_keys" {
  description = "Infra service SendGrid API keys (imported)"
  value = {
    for k, v in sendgrid_api_key.infra : k => v.api_key
  }
  sensitive = true
}

output "keygen_api_key" {
  description = "SendGrid API key for keygen service"
  value       = sendgrid_api_key.keygen.api_key
  sensitive   = true
}

output "mermaid_api_key" {
  description = "SendGrid API key for mermaid live editor"
  value       = sendgrid_api_key.mermaid.api_key
  sensitive   = true
}

output "project_api_keys" {
  description = "Per-project SendGrid API keys"
  value = {
    for k, v in module.project : k => v.api_key
  }
  sensitive = true
}

output "domain_auth_dns" {
  description = "CNAME records needed per project for SendGrid DKIM domain auth"
  value = {
    for k, v in module.project : k => {
      domain = local.projects[k].domain
      dns    = v.dkim_cnames
    }
  }
}
