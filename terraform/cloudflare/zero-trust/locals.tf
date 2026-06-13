# =============================================================================
# zero-trust — shared constants
# =============================================================================
# All identity, IP, and account constants live here. Edit this file to:
#   - Add/remove admin, developer, friend, or client email addresses
#   - Update trusted IP ranges (VPN changes, new office CIDRs)
#   - Add service token IDs for new automation clients
# =============================================================================

locals {
  cf_account_id = "a75e745949fc104ea4c4107a17158f15"

  # ── Role rosters ─────────────────────────────────────────────────────────
  cf_admins = [
    "keith.brings@noizu.com",
    "tynanoun@gmail.com",
  ]

  # Reserved for future hires. Empty → apps granting only developer access
  # are effectively admin-only until someone is added here.
  cf_developers = [
    # "new-dev@example.com",
  ]

  cf_friends = [
    "darin@slablab.com",
    "lainevc@gmail.com",
    "jenny@queenofswords.co",
    "dejennynfts@gmail.com",
    "ankit.savaliya@phycominc.com",
    "gusthemole@gmail.com",     # Darth Gustav
    "dreamer@vlrevolution.com", # Theo (VLRevolution)
    "accounts.mek@icloud.com",
    "charlie.robbins@gmail.com",
  ]

  # Clients: stub. External users granted per-product access when onboarding.
  cf_clients = [
    # "client@example.com",
  ]

  # ── Non-identity inclusions ───────────────────────────────────────────────
  cf_trusted_ips = [
    "58.97.218.0/24",
    "58.97.217.0/24",
    "5.183.32.253/32",
    "208.64.36.79/32",
    "208.64.36.80/32",
    "153.53.231.246/32",
  ]

  cf_service_token_ids = [
    "656602d8-fe39-4493-87a8-7618ce5236e5", # NPL
    # "38b5e368-41a1-4943-9645-28979b65f522", # OUNSOWN — uncomment when wiring
  ]
}
