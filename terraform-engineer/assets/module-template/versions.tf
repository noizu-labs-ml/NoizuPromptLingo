terraform {
  required_version = ">= 1.6"

  required_providers {
    # TODO: Replace with actual provider
    # Use floor constraints (>=) in modules, pessimistic (~>) in root
    example = {
      source  = "hashicorp/example"
      version = ">= 1.0"
    }
  }
}
