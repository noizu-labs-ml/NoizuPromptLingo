# =============================================================================
# noizu.com — DNS records (Cloudflare)
# =============================================================================
# Authoritative Terraform definition for the noizu.com zone.
#
# Organization:
#   1. Cluster A records (bulk for_each)
#   2. Special A records (root, www, ipmi, ops)
#   3. Microsoft 365 / Outlook CNAMEs
#   4. Google Workspace CNAMEs
#   5. DKIM selector CNAMEs
#   6. MX records
#   7. SRV records (Skype/Lync federation)
#   8. TXT records (SPF, verification)
#
# All zone ID and IP constants live in locals.tf.
# =============================================================================

locals {
  cluster_subdomains = toset([
    # Re-added 2026-05-26: keygen (license manager redeployment)
    # Added 2026-06-02: accounting (ERPNext)
    "accounting",
    "apm",
    "appsmith",
    "argocd",
    "blog",
    "bottlecrm",
    "chartdb",
    "chatterbox-tts",
    "cockpit",
    "code",
    "directus",
    "docmost",
    "drawio",
    "echelon",
    "espocrm",
    "eval",
    "excalidraw",
    "ghost",
    "growthbook",
    "hakatime",
    "headlamp",
    "inference",
    "infisical",
    "infra",
    "jupyter",
    "keygen",
    "kitten-tts",
    "kroki",
    "labelstudio",
    "langfuse",
    "listmonk",
    "litellm",
    "livecodes",
    "matomo",
    "mautic",
    "mermaid",
    "metabase",
    "minio",
    "minio-console",
    "mydraft",
    "n8n",
    "npm",
    "nb",
    "nextcloud",
    "oneuptime",
    "penpot",
    "plane",
    "plantuml",
    "posthog",
    "postiz",
    "seonaut",
    "serpbear",
    "taiga",
    "weaviate",
    "webstudio",
    "webui",
  ])
}

# ── 1. Cluster A records (proxied → primary server) ──────────────────────────

resource "cloudflare_dns_record" "cluster" {
  for_each = local.cluster_subdomains
  zone_id  = local.zone_id
  name     = each.key
  type     = "A"
  content  = local.ip
  proxied  = true
  ttl      = 1
}

# ── 2. Special A records ─────────────────────────────────────────────────────

resource "cloudflare_dns_record" "root" {
  zone_id = local.zone_id
  name    = "noizu.com"
  type    = "A"
  content = local.ip
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = local.zone_id
  name    = "www"
  type    = "A"
  content = local.ip
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "ipmi" {
  zone_id = local.zone_id
  name    = "ipmi"
  type    = "A"
  content = local.ipmi_ip
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "ops" {
  zone_id = local.zone_id
  name    = "ops"
  type    = "A"
  content = local.ip
  proxied = false
  ttl     = 1
}

# ── 3. Microsoft 365 / Outlook CNAMEs ────────────────────────────────────────

resource "cloudflare_dns_record" "autodiscover" {
  zone_id = local.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  content = "autodiscover.outlook.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "autodiscover_o365" {
  zone_id = local.zone_id
  name    = "autodiscover.o365"
  type    = "CNAME"
  content = "autodiscover.outlook.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "enterpriseenrollment" {
  zone_id = local.zone_id
  name    = "enterpriseenrollment"
  type    = "CNAME"
  content = "enterpriseenrollment-s.manage.microsoft.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "enterpriseenrollment_o365" {
  zone_id = local.zone_id
  name    = "enterpriseenrollment.o365"
  type    = "CNAME"
  content = "enterpriseenrollment-s.manage.microsoft.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "enterpriseregistration" {
  zone_id = local.zone_id
  name    = "enterpriseregistration"
  type    = "CNAME"
  content = "enterpriseregistration.windows.net"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "enterpriseregistration_o365" {
  zone_id = local.zone_id
  name    = "enterpriseregistration.o365"
  type    = "CNAME"
  content = "enterpriseregistration.windows.net"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "lyncdiscover" {
  zone_id = local.zone_id
  name    = "lyncdiscover"
  type    = "CNAME"
  content = "webdir.online.lync.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "lyncdiscover_o365" {
  zone_id = local.zone_id
  name    = "lyncdiscover.o365"
  type    = "CNAME"
  content = "webdir.online.lync.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sip" {
  zone_id = local.zone_id
  name    = "sip"
  type    = "CNAME"
  content = "sipdir.online.lync.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sip_o365" {
  zone_id = local.zone_id
  name    = "sip.o365"
  type    = "CNAME"
  content = "sipdir.online.lync.com"
  proxied = false
  ttl     = 1
}

# ── 4. Google Workspace CNAMEs ────────────────────────────────────────────────

resource "cloudflare_dns_record" "calendar" {
  zone_id = local.zone_id
  name    = "calendar"
  type    = "CNAME"
  content = "ghs.google.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "docs" {
  zone_id = local.zone_id
  name    = "docs"
  type    = "CNAME"
  content = "ghs.google.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "mail" {
  zone_id = local.zone_id
  name    = "mail"
  type    = "CNAME"
  content = "ghs.google.com"
  proxied = false
  ttl     = 1
}

# ── 5. DKIM selector CNAMEs (M365) ───────────────────────────────────────────

resource "cloudflare_dns_record" "dkim_selector1" {
  zone_id = local.zone_id
  name    = "selector1._domainkey"
  type    = "CNAME"
  content = "selector1-noizu-com._domainkey.noizulabs.onmicrosoft.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "dkim_selector2" {
  zone_id = local.zone_id
  name    = "selector2._domainkey"
  type    = "CNAME"
  content = "selector2-noizu-com._domainkey.noizulabs.onmicrosoft.com"
  proxied = false
  ttl     = 1
}

# ── 6. MX records ────────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "mx_google_primary" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "aspmx.l.google.com"
  priority = 0
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_google_alt1" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "alt1.aspmx.l.google.com"
  priority = 5
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_google_alt2" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "alt2.aspmx.l.google.com"
  priority = 5
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_google_aspmx2" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "aspmx2.googlemail.com"
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_google_aspmx3" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "aspmx3.googlemail.com"
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_outlook_fallback" {
  zone_id  = local.zone_id
  name     = "noizu.com"
  type     = "MX"
  content  = "noizu-com.mail.protection.outlook.com"
  priority = 65535
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_o365" {
  zone_id  = local.zone_id
  name     = "o365"
  type     = "MX"
  content  = "o365-noizu-com.mail.protection.outlook.com"
  priority = 1
  ttl      = 1
}

resource "cloudflare_dns_record" "mx_gsuite" {
  zone_id  = local.zone_id
  name     = "gsuite"
  type     = "MX"
  content  = "smtp.google.com"
  priority = 0
  ttl      = 1
}

# ── 7. SRV records (Skype/Lync federation) ───────────────────────────────────

resource "cloudflare_dns_record" "srv_sip_tls" {
  zone_id  = local.zone_id
  name     = "_sip._tls"
  type     = "SRV"
  priority = 100
  data = {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }
  ttl = 1
}

resource "cloudflare_dns_record" "srv_sipfederation" {
  zone_id  = local.zone_id
  name     = "_sipfederationtls._tcp"
  type     = "SRV"
  priority = 100
  data = {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }
  ttl = 1
}

# ── 8. TXT records ───────────────────────────────────────────────────────────

resource "cloudflare_dns_record" "txt_spf" {
  zone_id = local.zone_id
  name    = "noizu.com"
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com include:spf.protection.outlook.com ~all\""
  ttl     = 1
}

resource "cloudflare_dns_record" "txt_ms_verification" {
  zone_id = local.zone_id
  name    = "noizu.com"
  type    = "TXT"
  content = "\"MS=ms77670091\""
  ttl     = 1
}

resource "cloudflare_dns_record" "txt_openai" {
  zone_id = local.zone_id
  name    = "noizu.com"
  type    = "TXT"
  content = "openai-domain-verification=dv-uLj2HM8rczkL3HlnammQpG7p"
  ttl     = 1
}

resource "cloudflare_dns_record" "txt_google_verification" {
  zone_id = local.zone_id
  name    = "noizu.com"
  type    = "TXT"
  content = "google-site-verification=aUWTWa4bvssVjt8SaZkDYM97QO2csJ7l_4IFJZwRlCc"
  ttl     = 1
}

resource "cloudflare_dns_record" "txt_spf_o365" {
  zone_id = local.zone_id
  name    = "o365"
  type    = "TXT"
  content = "\"v=spf1 include:spf.protection.outlook.com -all\""
  ttl     = 1
}
