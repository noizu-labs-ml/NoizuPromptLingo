terraform {
  required_providers {
    sendgrid = {
      source  = "kenzo0107/sendgrid"
      version = "~> 2.9"
    }
  }
}

# =============================================================================
# SendGrid project module — API key + domain authentication per project
# =============================================================================
# Creates:
#   - sendgrid_api_key.this        (mail.send + templates.read)
#   - sendgrid_sender_authentication.this  (DKIM domain auth)
# =============================================================================

resource "sendgrid_api_key" "this" {
  name   = "k8-${var.project_key}"
  scopes = ["mail.send", "templates.read"]
}

resource "sendgrid_sender_authentication" "this" {
  domain             = var.domain
  automatic_security = true
}
