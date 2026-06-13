#!/bin/bash
# demo/root/scripts/deploy.sh — Runtime IPC via dc_set
# A child process updating named configs — parent shell sees changes via precmd hook.
# This isn't an .envrc — it's a script called from within a direnv-config session.

set -euo pipefail

APP="${1:?Usage: deploy.sh <app-name>}"
IMAGE="${2:?Usage: deploy.sh <app-name> <image:tag>}"

# --- Update tab config (parent shell's tab title updates automatically) ---
dc_set tab status "deploying $APP"
dc_set tab emoji rocket
dc_set tab urgency 2

echo "==> Building $APP..."
dc_set tab status "building $APP"
# make build ...
sleep 2

echo "==> Pushing $APP image..."
dc_set tab status "pushing $APP"
dc_set tab emoji ship
# docker push "$IMAGE" ...
sleep 1

echo "==> Helm upgrade..."
dc_set tab status "helm-upgrade $APP"
dc_set tab emoji construction
# helm upgrade --install ...
sleep 2

echo "==> Verifying rollout..."
dc_set tab status "verifying $APP"
dc_set tab emoji search
# kubectl rollout status ...
sleep 1

# --- Update the app's named config with deploy metadata ---
dc_set "app-${APP}" last_deploy "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
dc_set "app-${APP}" last_image "$IMAGE"
dc_set "app-${APP}" deploy_status "healthy"

# --- Final tab state ---
dc_set tab status "deployed $APP"
dc_set tab emoji check
dc_set tab urgency 5

echo "==> Done. $APP deployed as $IMAGE"
