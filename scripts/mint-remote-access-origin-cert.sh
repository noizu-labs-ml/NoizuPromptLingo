#!/usr/bin/env bash
#
# Mint a Cloudflare Origin CA certificate for the remote-access tunnel subsystem
# (*.remote-access.noizu.com), matching the repo's file-based TLS convention:
# the cert + key land in .secrets/tls/remote-access/{cert.pem,key.pem}, ready to
# be referenced from .infisical-secrets.yaml or sealed into apps-ns as
# `remote-access-tls-synced` (mirroring cloudflare-tls-synced).
#
# This calls the Cloudflare Origin CA API — it creates a REAL certificate.
# It does NOT touch the cluster or Cloudflare DNS.
#
# Auth (preferred → fallback):
#   CLOUDFLARE_API_TOKEN       an API token with "SSL and Certificates: Edit"
#                              (Origin CA). PREFERRED — Service Keys are deprecated
#                              by Cloudflare (stop working 2026-09-30).
#   CLOUDFLARE_ORIGIN_CA_KEY   the legacy account "Origin CA Key" (deprecated).
#
# Usage (reuse the noizu token already in your env):
#   CLOUDFLARE_API_TOKEN="$TF_VAR_noizu_cloudflare_api_token" \
#     ./scripts/mint-remote-access-origin-cert.sh
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"   # …/Noizu
OUT_DIR="${OUT_DIR:-$REPO_ROOT/.secrets/tls/remote-access}"
APEX="remote-access.noizu.com"
WILDCARD="*.remote-access.noizu.com"
VALIDITY="${VALIDITY:-5475}"   # days (~15y, Cloudflare Origin CA max)
API="https://api.cloudflare.com/client/v4/certificates"

command -v openssl >/dev/null || { echo "openssl is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }

mkdir -p "$OUT_DIR"
KEY="$OUT_DIR/key.pem"
CERT="$OUT_DIR/cert.pem"
CSR="$(mktemp -t ra-csr.XXXXXX).pem"
trap 'rm -f "$CSR"' EXIT

echo "▸ Generating 2048-bit RSA private key → $KEY"
openssl genrsa -out "$KEY" 2048 2>/dev/null
chmod 600 "$KEY"

echo "▸ Building CSR for CN=$APEX, SAN=[$WILDCARD, $APEX]"
openssl req -new -key "$KEY" -subj "/CN=$APEX" \
  -addext "subjectAltName=DNS:${WILDCARD},DNS:${APEX}" \
  -out "$CSR"

# Build the JSON request. hostnames must include both the wildcard and apex.
REQ_BODY="$(jq -n \
  --arg csr "$(cat "$CSR")" \
  --arg w "$WILDCARD" --arg a "$APEX" \
  --argjson validity "$VALIDITY" \
  '{hostnames: [$w, $a], requested_validity: $validity, request_type: "origin-rsa", csr: $csr}')"

echo "▸ Requesting Origin CA certificate from Cloudflare…"
if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  RESP="$(curl -sS -X POST "$API" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$REQ_BODY")"
elif [[ -n "${CLOUDFLARE_ORIGIN_CA_KEY:-}" ]]; then
  # Legacy/deprecated service-key path (works until 2026-09-30).
  RESP="$(curl -sS -X POST "$API" \
    -H "X-Auth-User-Service-Key: ${CLOUDFLARE_ORIGIN_CA_KEY}" \
    -H "Content-Type: application/json" \
    --data "$REQ_BODY")"
else
  echo "Set CLOUDFLARE_API_TOKEN (preferred) or CLOUDFLARE_ORIGIN_CA_KEY." >&2
  exit 1
fi

if [[ "$(jq -r '.success' <<<"$RESP")" != "true" ]]; then
  echo "✗ Cloudflare API error:" >&2
  jq -r '.errors' <<<"$RESP" >&2
  exit 1
fi

jq -r '.result.certificate' <<<"$RESP" > "$CERT"
chmod 644 "$CERT"

echo "✓ Wrote:"
echo "    $CERT"
echo "    $KEY"
echo
echo "Next steps (see scripts/REMOTE-ACCESS-CERT-README.md):"
echo "  1. Reference these in .infisical-secrets.yaml (remote-access-tls section), OR"
echo "  2. Seal into apps-ns as 'remote-access-tls-synced' (mirror cloudflare-tls-synced):"
echo "       kubectl create secret tls remote-access-tls-synced \\"
echo "         --cert=$CERT --key=$KEY -n apps-ns --dry-run=client -o yaml | kubeseal -o yaml > …"
echo "  3. The remote-access Helm chart ingress already references secretName: remote-access-tls-synced."
