#!/usr/bin/env bash
# Show current activation status: feature gates, resource counts, env vars.
#
# Usage: ./scripts/check-activation-status.sh

set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== Monitoring Activation Status ==="
echo

echo "--- Feature Gates ---"
terraform output -json activation_status 2>/dev/null | python3 -m json.tool || echo "(run terraform apply first)"
echo

echo "--- Alert Rules ---"
terraform output -json alert_rule_names 2>/dev/null | python3 -m json.tool || echo "(none)"
echo

echo "--- Notification Channels ---"
terraform output -json notification_channel_names 2>/dev/null | python3 -m json.tool || echo "(none)"
echo

echo "--- Routing Policies ---"
terraform output -json routing_policy_names 2>/dev/null | python3 -m json.tool || echo "(none)"
echo

echo "--- Required Environment ---"
for v in SIGNOZ_ACCESS_TOKEN TF_VAR_signoz_access_token TF_VAR_slack_webhook_url TF_VAR_ops_webhook_url; do
  if [[ -n "${!v:-}" ]]; then
    echo "  ✓ $v (set)"
  else
    echo "  ✗ $v (missing)"
  fi
done
echo

echo "=== Status Complete ==="
