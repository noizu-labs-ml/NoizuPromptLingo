# =============================================================================
# noizu.com — shared constants
# =============================================================================
# Single source of truth for zone ID and server IPs in this root.
# If the zone ID changes (e.g., zone migration), update it here only.
# =============================================================================

locals {
  zone_id  = "46014d24206a7141ed698d2d9d963e85"
  ip       = "208.64.36.79"   # primary cluster / server IP
  mail_ip  = "208.64.36.80"   # alt mail IP (MX / mail-adjacent records)
  ipmi_ip  = "208.64.36.78"   # IPMI BMC (out-of-band management)
}
