#!/usr/bin/env bash
#
# Generic env-driven installer for the Noizu remote-access tunnel client.
# Run this from inside the extracted remote-access-client/ directory:
#
#   export REMOTE_ACCESS_NAME=starlight-robot
#   export REMOTE_ACCESS_PORT=3000
#   export REMOTE_ACCESS_TOKEN=<mcp-jwt>
#   export REMOTE_ACCESS_ORG=<organization-id>
#   export REMOTE_ACCESS_API=https://tobor.locker        # optional
#   export REMOTE_ACCESS_SERVER=tunnel.noizu.com         # optional
#   bash install.sh
#
# The frontend's "Download install.sh" button generates a personalized variant
# that also downloads + untars this package and bakes in the name/token/org.
set -euo pipefail

cd "$(dirname "$0")"

: "${REMOTE_ACCESS_NAME:?set REMOTE_ACCESS_NAME (the subdomain to claim)}"
: "${REMOTE_ACCESS_PORT:?set REMOTE_ACCESS_PORT (the local port to expose)}"
: "${REMOTE_ACCESS_TOKEN:?set REMOTE_ACCESS_TOKEN (mint one from an MCP API key)}"
: "${REMOTE_ACCESS_ORG:?set REMOTE_ACCESS_ORG (your organization id)}"
export REMOTE_ACCESS_API="${REMOTE_ACCESS_API:-https://tobor.locker}"
export REMOTE_ACCESS_SERVER="${REMOTE_ACCESS_SERVER:-tunnel.noizu.com}"

echo "Installing dependencies (this also downloads the frpc binary)…"
npm install
echo "Building…"
npm run build
echo "Starting remote-access tunnel → https://${REMOTE_ACCESS_NAME}.remote-access.noizu.com (local 127.0.0.1:${REMOTE_ACCESS_PORT})"
exec node dist/index.js
