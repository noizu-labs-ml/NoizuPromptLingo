locals {
  # ── Existing infra service API keys (imported into state) ─────────────────
  # These 11 keys were provisioned outside Terraform and imported.
  infra_keys = {
    startapp      = { api_key_id = "0MesfP0NRdCff4vcyU0aQw" }
    infisical     = { api_key_id = "3vkZ10nLT0WBClCkM_h_2Q" }
    jupyterhub    = { api_key_id = "D_l83S7MQHiXVajQsOU_iA" }
    phoenix       = { api_key_id = "A4vQhUagTv-4oCq3qixpaA" }
    docmost       = { api_key_id = "Yljdxl--Qxu8jbqWH-nDvw" }
    nextcloud     = { api_key_id = "AkOWZqXaRSyz1XnTMS5dyQ" }
    taiga         = { api_key_id = "KrEtMwIYTSaocwrdURCZmg" }
    plane         = { api_key_id = "Wzfi9pEUSHqCj9J0mr-m1Q" }
    authentik     = { api_key_id = "vGJOR0BdRDGmgl8rTx2cwg" }
    bottlecrm     = { api_key_id = "gxGlfhbWTJCugn2THf5rYQ" }
    webmail-relay = { api_key_id = "RzzXoXTHQjuN8xureGzL1Q" }
  }

  # ── Portfolio projects — API key + domain auth via sendgrid-project module ─
  projects = {
    aifighter        = { domain = "aifighter.com",        from_address = "noreply@aifighter.com" }
    bladeofeternity  = { domain = "bladeofeternity.com",  from_address = "noreply@bladeofeternity.com" }
    bloggerscompete  = { domain = "bloggerscompete.com",  from_address = "noreply@bloggerscompete.com" }
    bookmarkflow     = { domain = "bookmarkflow.com",     from_address = "noreply@bookmarkflow.com" }
    codefresh        = { domain = "codefre.sh",           from_address = "noreply@codefre.sh" }
    derobotis        = { domain = "derobot.is",           from_address = "noreply@derobot.is" }
    gamesborn        = { domain = "gamesborn.com",        from_address = "noreply@gamesborn.com" }
    genai            = { domain = "genai.dev",            from_address = "noreply@genai.dev" }
    gottacc          = { domain = "gotta.cc",             from_address = "noreply@gotta.cc" }
    intellectparadox = { domain = "intellectparadox.ai",  from_address = "noreply@intellectparadox.ai" }
    iotgo            = { domain = "iotgo.io",             from_address = "noreply@iotgo.io" }
    jailbreakingsite = { domain = "jailbreakingsite.com", from_address = "noreply@jailbreakingsite.com" }
    noizu            = { domain = "noizu.com",            from_address = "noreply@noizu.com" }
    noizurpg         = { domain = "noizurpg.com",         from_address = "noreply@noizurpg.com" }
    robotsunite      = { domain = "robots-unite.com",     from_address = "noreply@robots-unite.com" }
    therobothelps    = { domain = "therobothelps.com",    from_address = "noreply@therobothelps.com" }
    therobotknows    = { domain = "therobotknows.com",    from_address = "noreply@therobotknows.com" }
    therobotlearns   = { domain = "therobotlearns.com",   from_address = "noreply@therobotlearns.com" }
    therobotlives    = { domain = "therobotlives.com",    from_address = "noreply@therobotlives.com" }
    therobotmakes    = { domain = "therobotmakes.com",    from_address = "noreply@therobotmakes.com" }
    therobotplans    = { domain = "therobotplans.com",    from_address = "noreply@therobotplans.com" }
  }

  # Pre-existing SendGrid domain auth IDs to import
  existing_domain_auth = {
    therobotlives = { id = 30852403 }
  }
}
