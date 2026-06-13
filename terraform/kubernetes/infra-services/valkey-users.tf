# ---------------------------------------------------------------------------
# Shared-Valkey ACL credentials for the apps.
# ---------------------------------------------------------------------------
# The ACL user passwords are owned by the init module (single source of truth).
# We materialise a per-app Secret (username + password) here so the apps can
# reference them, keeping the values in sync with the infra valkey ACL file.
locals {
  shared_valkey_users = try(data.terraform_remote_state.init.outputs.shared_valkey_users, {})

  # Apps that authenticate to infra-valkey as their own ACL user.
  valkey_app_users = ["posthog", "authentik", "infisical"]
}

resource "kubernetes_secret_v1" "valkey_user" {
  for_each = toset(local.valkey_app_users)

  metadata {
    name      = "${each.key}-valkey"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = each.key })
  }
  type = "Opaque"
  data = {
    VALKEY_USERNAME = each.key
    VALKEY_PASSWORD = lookup(local.shared_valkey_users, each.key, "")
  }
}
