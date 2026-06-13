variable "project_key" {
  description = "Short identifier used to name the API key (e.g. codefresh)"
  type        = string
}

variable "domain" {
  description = "Domain to authenticate with SendGrid (e.g. codefre.sh)"
  type        = string
}

variable "noreply_address" {
  description = "From address for outbound email (e.g. noreply@codefre.sh)"
  type        = string
}
