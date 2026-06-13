variable "domain" {
  description = "Domain name for the Cloudflare zone (e.g. noizulabs.com)"
  type        = string
}

variable "account_id" {
  description = "Cloudflare account ID that owns the zone"
  type        = string
}

variable "server_ip" {
  description = "Primary server IP for the root A record"
  type        = string
}

variable "proxied" {
  description = "Whether the root A record is proxied through Cloudflare"
  type        = bool
  default     = true
}

variable "add_www" {
  description = "Whether to add a www CNAME pointing to the root domain"
  type        = bool
  default     = false
}
