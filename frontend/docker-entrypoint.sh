#!/bin/sh
# Generate runtime config from environment variables.
# Loaded by the browser via <script src="/__env.js"> before the app hydrates.
# Helm values → K8s env vars → this script → window.__ENV

cat > /app/public/__env.js <<EOF
window.__ENV = {
  GA_MEASUREMENT_ID: "${GA_MEASUREMENT_ID:-}",
  POSTHOG_KEY: "${POSTHOG_KEY:-}",
  POSTHOG_HOST: "${POSTHOG_HOST:-}",
  API_URL: "${API_URL:-}",
  OTEL_COLLECTOR_URL: "${OTEL_COLLECTOR_URL:-}"
};
EOF

exec node server.js
