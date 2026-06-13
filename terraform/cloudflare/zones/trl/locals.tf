locals {
  # NOTE: Replace with the real TRL Cloudflare account ID
  account_id = "PLACEHOLDER_TRL_ACCOUNT_ID"
  server_ip  = "208.64.36.79"

  domains = toset([
    "artificialbeingsanonymo.us",
    "bewarethetobor.com",
    "derobot.is",
    "therobot.bond",
    "therobot.codes",
    "therobot.courses",
    "therobot.institute",
    "therobot.live",
    "therobot.study",
    "therobot.support",
    "therobot.ventures",
    "therobot.work",
    "therobotedoesitall.com",
    "therobotknows.com",
    "therobotlearns.com",
    "therobotmakes.com",
    "therobotplans.com",
    "therobotsrise.com",
    "therobotstates.com",
    "tobor.help",
    "tobor.locker",
    "tobor.wiki",
    "tobornalp.com",
  ])
}
