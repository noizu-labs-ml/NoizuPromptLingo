# =============================================================================
# therobotlives.com — DNS records (Cloudflare)
# =============================================================================
# Mail infrastructure (Mailu) + web services.
# All zone ID, IPs, and DKIM key live in locals.tf.
# =============================================================================

# ── A Records ────────────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "root" {
  zone_id = local.zone_id
  name    = "therobotlives.com"
  type    = "A"
  content = local.ip
  proxied = true
  ttl     = 1
}

# mail.therobotlives.com — NOT proxied (SMTP needs direct IP)
resource "cloudflare_dns_record" "mail" {
  zone_id = local.zone_id
  name    = "mail"
  type    = "A"
  content = local.mail_ip
  proxied = false
  ttl     = 1
}

# Mailu admin UI (proxied)
resource "cloudflare_dns_record" "mail_admin" {
  zone_id = local.zone_id
  name    = "mail-admin"
  type    = "A"
  content = local.mail_ip
  proxied = true
  ttl     = 1
}

# Roundcube webmail (proxied)
resource "cloudflare_dns_record" "webmail" {
  zone_id = local.zone_id
  name    = "webmail"
  type    = "A"
  content = local.mail_ip
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "kb" {
  zone_id = local.zone_id
  name    = "kb"
  type    = "A"
  content = local.ip
  proxied = true
  ttl     = 1
}

# autoconfig — Mailu serves autoconfig XML (Thunderbird/other clients)
resource "cloudflare_dns_record" "autoconfig" {
  zone_id = local.zone_id
  name    = "autoconfig"
  type    = "A"
  content = local.mail_ip
  proxied = false
  ttl     = 1
}

# mta-sts — serves MTA-STS policy file
resource "cloudflare_dns_record" "mta_sts" {
  zone_id = local.zone_id
  name    = "mta-sts"
  type    = "A"
  content = local.mail_ip
  proxied = true
  ttl     = 1
}

# ── SRV Records ──────────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "autodiscover_srv" {
  zone_id = local.zone_id
  name    = "_autodiscover._tcp"
  type    = "SRV"
  data = {
    priority = 0
    weight   = 1
    port     = 443
    target   = "mail.therobotlives.com"
  }
  ttl = 1
  lifecycle {
    ignore_changes = [priority]
  }
}

# ── MX Record ────────────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "mx" {
  zone_id  = local.zone_id
  name     = "therobotlives.com"
  type     = "MX"
  content  = "mail.therobotlives.com"
  priority = 10
  ttl      = 1
}

# ── TXT Records (Email Authentication) ───────────────────────────────────────

resource "cloudflare_dns_record" "spf" {
  zone_id = local.zone_id
  name    = "therobotlives.com"
  type    = "TXT"
  content = "v=spf1 a:mail.therobotlives.com include:sendgrid.net -all"
  ttl     = 1
}

resource "cloudflare_dns_record" "dkim" {
  zone_id = local.zone_id
  name    = "dkim._domainkey"
  type    = "TXT"
  content = "v=DKIM1; k=rsa; p=${local.dkim_pubkey}"
  ttl     = 1
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1; p=reject; rua=mailto:postmaster@therobotlives.com; ruf=mailto:postmaster@therobotlives.com; fo=1"
  ttl     = 1
}

resource "cloudflare_dns_record" "google_site_verification" {
  zone_id = local.zone_id
  name    = "therobotlives.com"
  type    = "TXT"
  content = "google-site-verification=7xfRntdVLkL25qLmC8OmnwqbMnF4niLWHzMIIivWHU0"
  ttl     = 1
}

resource "cloudflare_dns_record" "mta_sts_txt" {
  zone_id = local.zone_id
  name    = "_mta-sts"
  type    = "TXT"
  content = "v=STSv1; id=20260323"
  ttl     = 1
}

resource "cloudflare_dns_record" "tlsrpt" {
  zone_id = local.zone_id
  name    = "_smtp._tls"
  type    = "TXT"
  content = "v=TLSRPTv1; rua=mailto:postmaster@therobotlives.com"
  ttl     = 1
}

# ── SendGrid Domain Authentication CNAMEs ────────────────────────────────────

resource "cloudflare_dns_record" "sendgrid_em" {
  zone_id = local.zone_id
  name    = "em7722"
  type    = "CNAME"
  content = "u106945831.wl082.sendgrid.net"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sendgrid_dkim_s1" {
  zone_id = local.zone_id
  name    = "s1._domainkey"
  type    = "CNAME"
  content = "s1.domainkey.u106945831.wl082.sendgrid.net"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sendgrid_dkim_s2" {
  zone_id = local.zone_id
  name    = "s2._domainkey"
  type    = "CNAME"
  content = "s2.domainkey.u106945831.wl082.sendgrid.net"
  proxied = false
  ttl     = 1
}
