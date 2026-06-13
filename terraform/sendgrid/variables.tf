variable "sendgrid_admin_api_key" {
  description = "SendGrid admin API key (used to provision sub-keys and domain auth)"
  type        = string
  sensitive   = true
}
