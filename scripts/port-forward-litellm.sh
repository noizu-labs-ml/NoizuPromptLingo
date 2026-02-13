#!/usr/bin/env bash
# Keep kubectl port-forward to litellm alive, reconnecting on exit.
set -euo pipefail

NS="webui-ns"
SVC="svc/litellm"
LOCAL_PORT=4111
REMOTE_PORT=4000

while true; do
  echo "[$(date)] Starting port-forward ${SVC} ${LOCAL_PORT}:${REMOTE_PORT} ..."
  kubectl port-forward -n "$NS" "$SVC" "${LOCAL_PORT}:${REMOTE_PORT}" || true
  echo "[$(date)] Port-forward exited. Reconnecting in 2s ..."
  sleep 2
done
