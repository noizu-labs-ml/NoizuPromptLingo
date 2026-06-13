terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_zone" "this" {
  account = { id = var.account_id }
  name    = var.domain
}

resource "cloudflare_dns_record" "root" {
  zone_id = cloudflare_zone.this.id
  name    = var.domain
  type    = "A"
  content = var.server_ip
  proxied = var.proxied
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  count   = var.add_www ? 1 : 0
  zone_id = cloudflare_zone.this.id
  name    = "www"
  type    = "CNAME"
  content = var.domain
  proxied = var.proxied
  ttl     = 1
}
