# =============================================================================
# NetworkPolicy — restrict SMTP relay access to Mailu pods only.
# =============================================================================
# Prevents non-Mailu pods from reaching Postfix on port 25 (which relays all
# outbound mail through SendGrid). Services that need to send email should use
# SendGrid directly (smtp.sendgrid.net:587).
# =============================================================================
resource "kubernetes_network_policy_v1" "postfix_ingress_restrict" {
  metadata {
    name      = "postfix-ingress-restrict"
    namespace = local.ns
    labels    = local.common_labels
  }
  spec {
    pod_selector {
      match_labels = { app = "postfix" }
    }
    policy_types = ["Ingress"]
    ingress {
      # Only Mailu internal services — NOT roundcube (roundcube sends via front,
      # which enforces SMTP AUTH before forwarding to postfix).
      dynamic "from" {
        for_each = ["front", "admin", "rspamd", "dovecot"]
        content {
          pod_selector {
            match_labels = { app = from.value }
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 25
      }
      ports {
        protocol = "TCP"
        port     = 10025
      }
    }
  }
}
