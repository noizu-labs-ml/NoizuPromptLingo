output "nameservers" {
  description = "Cloudflare nameservers per domain — set these at the registrar"
  value = {
    for domain, zone in cloudflare_zone.this : domain => zone.name_servers
  }
}

output "zone_ids" {
  description = "Cloudflare zone IDs per domain"
  value = {
    for domain, zone in cloudflare_zone.this : domain => zone.id
  }
}
