terraform {
  required_version = ">= 1.5.0"
  required_providers {
    sendgrid = {
      source  = "kenzo0107/sendgrid"
      version = "~> 2.9"
    }
  }
}

provider "sendgrid" {
  api_key = var.sendgrid_admin_api_key
}
