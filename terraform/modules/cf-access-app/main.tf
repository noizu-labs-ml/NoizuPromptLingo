terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# CF Access App module — one application + standard 3-policy set
# =============================================================================
# Creates:
#   - cloudflare_zero_trust_access_application.this
#   - cloudflare_zero_trust_access_policy.team         (allow, group-based)
#   - cloudflare_zero_trust_access_policy.service_tokens (non_identity)
#   - cloudflare_zero_trust_access_policy.trusted_ips  (bypass)
# =============================================================================

resource "cloudflare_zero_trust_access_application" "this" {
  account_id = var.account_id

  name   = "${var.name} (noizu.com)"
  domain = var.domain
  type   = "self_hosted"

  session_duration           = var.session_duration
  auto_redirect_to_identity  = false
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "lax"
  skip_interstitial          = true
  app_launcher_visible       = var.app_launcher_visible

  policies = [
    { id = cloudflare_zero_trust_access_policy.team.id },
    { id = cloudflare_zero_trust_access_policy.service_tokens.id },
    { id = cloudflare_zero_trust_access_policy.trusted_ips.id },
  ]
}

resource "cloudflare_zero_trust_access_policy" "team" {
  account_id = var.account_id

  name     = "Team (${join(" + ", var.perms)})"
  decision = "allow"

  include = [
    for p in var.perms : {
      group = { id = var.group_ids[p] }
    }
  ]
}

resource "cloudflare_zero_trust_access_policy" "service_tokens" {
  account_id = var.account_id

  name     = "Service tokens (non-identity)"
  decision = "non_identity"

  include = [
    { group = { id = var.service_token_group_id } },
  ]
}

resource "cloudflare_zero_trust_access_policy" "trusted_ips" {
  account_id = var.account_id

  name     = "Trusted IPs (bypass)"
  decision = "bypass"

  include = [
    { group = { id = var.trusted_ip_group_id } },
  ]
}
