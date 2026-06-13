# =============================================================================
# Cloudflare Zero Trust — Explicit Access Applications
# =============================================================================
# Apps with custom policy wiring that don't fit the bulk 3-policy pattern:
#   - argocd: admins + developers only (no friends/clients)
#   - livebook: admins + developers + friends, plus path-scoped /public bypass
#   - apm: moved out of bulk — trusted IPs need bypass (headless Terraform auth)
#   - minio: moved out of bulk — S3 clients can't complete identity login flow
# =============================================================================

# ── argocd.noizu.com ─────────────────────────────────────────────────────────

module "argocd" {
  source = "../../modules/cf-access-app"

  account_id             = local.cf_account_id
  name                   = "Argocd"
  domain                 = "argocd.noizu.com"
  perms                  = ["admin", "developer"]
  group_ids              = local.cf_group_ids
  service_token_group_id = cloudflare_zero_trust_access_group.service_tokens.id
  trusted_ip_group_id    = cloudflare_zero_trust_access_group.trusted_ips.id
}

# ── nb.noizu.com (Livebook) ──────────────────────────────────────────────────
# Wider access (+ friends) and requires a path-scoped public bypass app so
# Kino widget JS can load without Access redirects from dynamic import().

module "livebook" {
  source = "../../modules/cf-access-app"

  account_id             = local.cf_account_id
  name                   = "Livebook"
  domain                 = "nb.noizu.com"
  perms                  = ["admin", "developer", "friend"]
  group_ids              = local.cf_group_ids
  service_token_group_id = cloudflare_zero_trust_access_group.service_tokens.id
  trusted_ip_group_id    = cloudflare_zero_trust_access_group.trusted_ips.id
}

# nb.noizu.com/public — path-scoped bypass so Kino widget assets load without
# the Access 302 → login redirect that dynamic import() can't follow.
# CF resolves the most-specific-path match first.
resource "cloudflare_zero_trust_access_application" "livebook_public" {
  account_id = local.cf_account_id

  name   = "Livebook public assets (nb.noizu.com/public)"
  domain = "nb.noizu.com/public"
  type   = "self_hosted"

  session_duration           = "24h"
  auto_redirect_to_identity  = false
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "lax"
  skip_interstitial          = true
  app_launcher_visible       = false

  policies = [
    { id = cloudflare_zero_trust_access_policy.livebook_public_bypass.id },
  ]
}

resource "cloudflare_zero_trust_access_policy" "livebook_public_bypass" {
  account_id = local.cf_account_id

  name     = "Bypass (public widget assets)"
  decision = "bypass"

  include = [
    { everyone = {} },
  ]
}

# ── apm.noizu.com (SigNoz APM) ───────────────────────────────────────────────
# Explicit (not bulk) so trusted IPs get a bypass decision. Headless Terraform
# provider can't complete Cloudflare's identity login flow.

module "apm" {
  source = "../../modules/cf-access-app"

  account_id             = local.cf_account_id
  name                   = "APM"
  domain                 = "apm.noizu.com"
  perms                  = ["admin", "developer", "friend"]
  group_ids              = local.cf_group_ids
  service_token_group_id = cloudflare_zero_trust_access_group.service_tokens.id
  trusted_ip_group_id    = cloudflare_zero_trust_access_group.trusted_ips.id
}

# ── minio.noizu.com (MinIO API) ───────────────────────────────────────────────
# Explicit (not bulk) so S3 clients bypass Access entirely — they cannot
# complete Cloudflare's identity login flow.

module "minio" {
  source = "../../modules/cf-access-app"

  account_id             = local.cf_account_id
  name                   = "MinIO API"
  domain                 = "minio.noizu.com"
  perms                  = ["admin"]
  group_ids              = local.cf_group_ids
  service_token_group_id = cloudflare_zero_trust_access_group.service_tokens.id
  trusted_ip_group_id    = cloudflare_zero_trust_access_group.trusted_ips.id
}
