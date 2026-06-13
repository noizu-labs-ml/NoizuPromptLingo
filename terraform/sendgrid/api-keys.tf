# =============================================================================
# SendGrid API keys
# =============================================================================

# ── Infra service keys (pre-existing, imported) ───────────────────────────────
resource "sendgrid_api_key" "infra" {
  for_each = { for k, v in local.infra_keys : k => v if v.api_key_id != "" }

  name   = each.key
  scopes = ["mail.send", "templates.read"]

  lifecycle {
    ignore_changes = [name]
  }
}

import {
  for_each = { for k, v in local.infra_keys : k => v if v.api_key_id != "" }
  to       = sendgrid_api_key.infra[each.key]
  id       = each.value.api_key_id
}

# ── Keygen — new infra key (no pre-existing ID) ───────────────────────────────
resource "sendgrid_api_key" "keygen" {
  name   = "keygen"
  scopes = ["mail.send", "templates.read"]
}

# ── Mermaid Live Editor ───────────────────────────────────────────────────────
resource "sendgrid_api_key" "mermaid" {
  name   = "mermaid"
  scopes = ["mail.send"]
}
