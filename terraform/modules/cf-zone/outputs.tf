output "zone_id" {
  description = "Cloudflare zone ID"
  value       = cloudflare_zone.this.id
}

output "nameservers" {
  description = "Cloudflare nameservers to set at the registrar"
  value       = cloudflare_zone.this.name_servers
}
