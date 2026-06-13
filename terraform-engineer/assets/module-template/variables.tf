variable "name" {
  type        = string
  description = "Name for the resource"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,62}$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens, 3-63 characters."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
