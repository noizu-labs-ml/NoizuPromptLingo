# =============================================================================
# Cloudflare Zero Trust — Access Groups (reusable membership lists)
# =============================================================================
# Groups are account-scoped, referenced from per-app policies.
# Edit locals.tf to change membership without touching this file.
# =============================================================================

resource "cloudflare_zero_trust_access_group" "admins" {
  account_id = local.cf_account_id
  name       = "admins"

  include = [
    for email in local.cf_admins : { email = { email = email } }
  ]
}

resource "cloudflare_zero_trust_access_group" "developers" {
  account_id = local.cf_account_id
  name       = "developers"

  # CF rejects empty `include`. Placeholder never matches anyone until a real
  # developer is added to cf_developers in locals.tf.
  include = length(local.cf_developers) > 0 ? [
    for email in local.cf_developers : { email = { email = email } }
    ] : [
    { email = { email = "placeholder-developer@noizu.com" } }
  ]
}

resource "cloudflare_zero_trust_access_group" "friends" {
  account_id = local.cf_account_id
  name       = "friends"

  include = [
    for email in local.cf_friends : { email = { email = email } }
  ]
}

resource "cloudflare_zero_trust_access_group" "clients" {
  account_id = local.cf_account_id
  name       = "clients"

  include = length(local.cf_clients) > 0 ? [
    for email in local.cf_clients : { email = { email = email } }
    ] : [
    { email = { email = "placeholder-client@noizu.com" } }
  ]
}

resource "cloudflare_zero_trust_access_group" "trusted_ips" {
  account_id = local.cf_account_id
  name       = "trusted-ips"

  include = [
    for ip in local.cf_trusted_ips : { ip = { ip = ip } }
  ]
}

resource "cloudflare_zero_trust_access_group" "service_tokens" {
  account_id = local.cf_account_id
  name       = "service-tokens"

  include = [
    for tid in local.cf_service_token_ids : { service_token = { token_id = tid } }
  ]
}

# ── Convenience locals for downstream policy files ───────────────────────────

locals {
  cf_group_ids = {
    admin     = cloudflare_zero_trust_access_group.admins.id
    developer = cloudflare_zero_trust_access_group.developers.id
    friend    = cloudflare_zero_trust_access_group.friends.id
    client    = cloudflare_zero_trust_access_group.clients.id
  }
}
