#!/usr/bin/env bash
#
# Generic env-driven installer for the Noizu browser controller.
# Run this from inside the extracted browser-controller/ directory:
#
#   export BROWSER_CONTROLLER_TOKEN=<mcp-jwt>
#   export BROWSER_CONTROLLER_ORG=<organization-id>
#   export BROWSER_CONTROLLER_URL=wss://tobor.locker/socket   # optional
#   bash install.sh
#
# The frontend's "Download install.sh" button generates a personalized variant
# that also downloads + untars this package and bakes in the token/org/url.
set -euo pipefail

cd "$(dirname "$0")"

: "${BROWSER_CONTROLLER_TOKEN:?set BROWSER_CONTROLLER_TOKEN (mint one from an MCP API key)}"
: "${BROWSER_CONTROLLER_ORG:?set BROWSER_CONTROLLER_ORG (your organization id)}"
export BROWSER_CONTROLLER_URL="${BROWSER_CONTROLLER_URL:-wss://tobor.locker/socket}"

echo "Installing dependencies (this also downloads Chromium via Playwright)…"
npm install
echo "Building…"
npm run build
# Headed by default for the local interactive install, so OIDC/SSO logins
# (e.g. authentik on tobor.locker) can be completed in a visible window. The
# Docker/CI image stays headless (it builds from the image, not this script).
# Override for unattended local runs with: BROWSER_CONTROLLER_HEADED=false
export BROWSER_CONTROLLER_HEADED="${BROWSER_CONTROLLER_HEADED:-true}"
echo "Starting browser controller → ${BROWSER_CONTROLLER_URL} (org ${BROWSER_CONTROLLER_ORG}, headed=${BROWSER_CONTROLLER_HEADED})"
exec node dist/index.js
