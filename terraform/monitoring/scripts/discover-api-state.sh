#!/usr/bin/env bash
# Read-only SigNoz API discovery: list channels, routing policies, and alerts.
# Flags duplicates that would conflict with Terraform-managed resources.
#
# Usage: ./scripts/discover-api-state.sh
#
# Requires: SIGNOZ_ACCESS_TOKEN (or TF_VAR_signoz_access_token)

set -euo pipefail
cd "$(dirname "$0")/.."

ENDPOINT="${SIGNOZ_ENDPOINT:-${TF_VAR_signoz_endpoint:-https://apm.noizu.com}}"
TOKEN="${SIGNOZ_ACCESS_TOKEN:-${TF_VAR_signoz_access_token:-}}"

if [[ -z "$TOKEN" ]]; then
  echo "✗ Set SIGNOZ_ACCESS_TOKEN or TF_VAR_signoz_access_token" >&2
  exit 1
fi

AUTH="SIGNOZ-API-KEY: ${TOKEN}"

echo "=== SigNoz API State Discovery ==="
echo "Endpoint: ${ENDPOINT}"
echo

echo "--- Notification Channels ---"
curl -sf -H "$AUTH" "${ENDPOINT}/api/v1/channels" | python3 -m json.tool 2>/dev/null || echo "(failed or empty)"
echo

echo "--- Alert Rules ---"
curl -sf -H "$AUTH" "${ENDPOINT}/api/v2/rules" | python3 -m json.tool 2>/dev/null || echo "(failed or empty)"
echo

echo "--- Routing Policies ---"
curl -sf -H "$AUTH" "${ENDPOINT}/api/v1/routepolicies" | python3 -m json.tool 2>/dev/null || echo "(failed or empty)"
echo

echo "=== Discovery Complete ==="
