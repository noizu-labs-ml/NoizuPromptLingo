# =============================================================================
# Portfolio project API keys + domain authentication
# =============================================================================
# Each project gets a SendGrid API key (mail.send + templates.read) and
# DKIM sender authentication via the sendgrid-project module.
# =============================================================================

module "project" {
  for_each = local.projects
  source   = "../modules/sendgrid-project"

  project_key     = each.key
  domain          = each.value.domain
  noreply_address = each.value.from_address
}

# Import pre-existing domain auth records into the module's managed resource.
import {
  for_each = local.existing_domain_auth
  to       = module.project[each.key].sendgrid_sender_authentication.this
  id       = tostring(each.value.id)
}
