resource "cloudflare_zone" "this" {
  for_each = local.domains
  account  = { id = local.account_id }
  name     = each.key
}

resource "cloudflare_dns_record" "root" {
  for_each = local.domains
  zone_id  = cloudflare_zone.this[each.key].id
  name     = each.key
  type     = "A"
  content  = local.server_ip
  proxied  = true
  ttl      = 1
}
