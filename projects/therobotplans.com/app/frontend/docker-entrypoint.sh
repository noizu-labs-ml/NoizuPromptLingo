#!/bin/sh
# =============================================================================
# Runtime environment injection for tobornalp.com frontend.
#
# Generates /app/public/__env.js from K8s environment variables so the browser
# can access runtime config without rebuilding the image. Loaded via
# <script src="/__env.js"> before the app hydrates.
#
# Flow: Helm values → K8s env vars → this script → window.__ENV
# =============================================================================

cat > /app/public/__env.js <<EOF
window.__ENV = {
  API_URL: "${API_URL:-}",
  GA_MEASUREMENT_ID: "${GA_MEASUREMENT_ID:-}",
  POSTHOG_KEY: "${POSTHOG_KEY:-}",
  POSTHOG_HOST: "${POSTHOG_HOST:-}",
  OTEL_COLLECTOR_URL: "${OTEL_COLLECTOR_URL:-}"
};
EOF

exec node server.js
