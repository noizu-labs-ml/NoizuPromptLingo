#!/usr/bin/env bash
# Run terraform commands with kubectl port-forward to SigNoz query service.
# Use when Cloudflare Access blocks direct provider access to apm.noizu.com.
#
# Usage: ./scripts/tf-with-portforward.sh plan
#        ./scripts/tf-with-portforward.sh apply

set -euo pipefail
cd "$(dirname "$0")/.."

LOCAL_PORT="${SIGNOZ_LOCAL_PORT:-3301}"
NAMESPACE="observability-ns"
SERVICE="svc/signoz-frontend"
REMOTE_PORT="3301"

cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "$PF_PID" 2>/dev/null || true
    wait "$PF_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "→ Starting port-forward ${NAMESPACE}/${SERVICE}:${REMOTE_PORT} → localhost:${LOCAL_PORT}"
kubectl port-forward -n "$NAMESPACE" "$SERVICE" "${LOCAL_PORT}:${REMOTE_PORT}" &
PF_PID=$!
sleep 2

if ! kill -0 "$PF_PID" 2>/dev/null; then
  echo "✗ Port-forward failed to start" >&2
  exit 1
fi

export TF_VAR_signoz_endpoint="http://localhost:${LOCAL_PORT}"
echo "→ TF_VAR_signoz_endpoint=${TF_VAR_signoz_endpoint}"
echo "→ Running: terraform $*"
terraform "$@"
