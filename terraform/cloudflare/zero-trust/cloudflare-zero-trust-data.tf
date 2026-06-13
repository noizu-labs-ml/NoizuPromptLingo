# =============================================================================
# Cloudflare Zero Trust — Read-only data sources
# =============================================================================
# Pulls org-level settings so other resources / outputs can compose values
# like `<team>.cloudflareaccess.com` without hardcoding the team name.
# =============================================================================

data "cloudflare_zero_trust_organization" "noizu" {
  account_id = local.cf_account_id
}

locals {
  # Strip .cloudflareaccess.com suffix → short team identifier
  # that Livebook's ZTA module expects: cloudflare:<team>:<AUD>
  cf_team_name = trimsuffix(
    data.cloudflare_zero_trust_organization.noizu.auth_domain,
    ".cloudflareaccess.com"
  )
}
