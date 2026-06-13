# =============================================================================
# therobotlives.com — shared constants
# =============================================================================

locals {
  zone_id  = "9793b9931a64f208b725d39ab70740e0"
  ip       = "208.64.36.79"  # primary cluster / server IP
  mail_ip  = "208.64.36.80"  # dedicated mail server IP (Mailu)

  # DKIM public key (from Mailu rspamd /dkim/therobotlives.com.dkim.key)
  dkim_pubkey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq2I9x6VHCHI0qi2DgSDfIGyyqfbxtrO8D//yg3pdcSGGFpk+DP3iTC6lTT+KGP2Rd0iMFhInZOxHkynh7acfQhs7m3c/HiSGPwTGWXy8cg3GPuAfHraFh5rapZ9ebi58S0zwMgtBLB/6GOwZcHSzzZyDVOSlRa7opBu5b+d8EWOhhyjb+xVMQaldZyxdIBrOoCilg4vAlHUeA6rjTqEG0IHU7Jo0GRsvAUpwS+XmYZdVn9EDZgVY329CVmzFzJ2zXT8fA8Yr32cohiBDW4mqvRbtfk+X2wxQyYh4yUWDP/HEHxRw8wohoutd5htPgQNuhwVIDAwm/wdgPCxzFplbyQIDAQAB"
}
