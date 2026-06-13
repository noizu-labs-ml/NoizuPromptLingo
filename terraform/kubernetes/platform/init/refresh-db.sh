#!/usr/bin/env bash
# Refresh the platform-tier shared databases — re-run init / re-apply creds
# without (by default) destroying data. Mirrors infra/refresh-db.sh.
#
# Background:
#   * Postgres/TimescaleDB only runs /docker-entrypoint-initdb.d scripts when
#     PGDATA is EMPTY. Restarting the pod does NOT re-run the per-app
#     init-db.sh, so we exec the (idempotent) 1NN-<app>.sh scripts against the
#     live pod instead.
#   * Valkey reads its password from the Infisical-managed secret as env, so a
#     rollout restart is enough to pick up a rotated password.
#
# Usage:
#   ./refresh-db.sh                 # refresh both, keep data (default)
#   ./refresh-db.sh postgres        # only Postgres/Timescale
#   ./refresh-db.sh valkey          # only Valkey
#   ./refresh-db.sh --wipe          # DESTRUCTIVE: delete PVCs + recreate (both)
#   ./refresh-db.sh --wipe postgres # DESTRUCTIVE: wipe only Postgres data
#
# --wipe deletes the data PVC so the next pod comes up fresh; you must run
# `terragrunt apply` (or `terraform apply`) afterwards to recreate the PVC + roll
# the pod.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# Platform tier lives in the `platform` namespace (platform/init variables.tf).
NS="${NS:-platform}"

PG_DEPLOY="platform-timescaledb"
VALKEY_DEPLOY="platform-valkey"

WIPE=0
TARGET="both"
for arg in "$@"; do
  case "$arg" in
    --wipe)             WIPE=1 ;;
    postgres|timescale) TARGET="postgres" ;;
    valkey)             TARGET="valkey" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

echo "Namespace: $NS  |  target: $TARGET  |  wipe: $WIPE"

refresh_postgres() {
  if [[ "$WIPE" == 1 ]]; then
    echo "==> WIPING Postgres/Timescale data (${PG_DEPLOY}-data)"
    kubectl -n "$NS" scale deploy/"$PG_DEPLOY" --replicas=0
    kubectl -n "$NS" delete pvc "${PG_DEPLOY}-data" --ignore-not-found
    echo "    PVC deleted. Run: terragrunt apply (in $HERE)"
  else
    echo "==> Re-running per-app initdb scripts on $PG_DEPLOY (idempotent, keeps data)"
    kubectl -n "$NS" exec deploy/"$PG_DEPLOY" -c timescaledb -- \
      bash -c 'set -e; shopt -s nullglob; for f in /docker-entrypoint-initdb.d/1*.sh; do echo "-- $f"; bash "$f"; done'
  fi
}

refresh_valkey() {
  if [[ "$WIPE" == 1 ]]; then
    echo "==> WIPING Valkey data (${VALKEY_DEPLOY}-data)"
    kubectl -n "$NS" scale deploy/"$VALKEY_DEPLOY" --replicas=0
    kubectl -n "$NS" delete pvc "${VALKEY_DEPLOY}-data" --ignore-not-found
    echo "    PVC deleted. Run: terragrunt apply (in $HERE)"
  else
    echo "==> Rolling $VALKEY_DEPLOY to pick up a rotated password (keeps data)"
    kubectl -n "$NS" rollout restart deploy/"$VALKEY_DEPLOY"
    kubectl -n "$NS" rollout status  deploy/"$VALKEY_DEPLOY" --timeout=120s
  fi
}

case "$TARGET" in
  postgres) refresh_postgres ;;
  valkey)   refresh_valkey ;;
  both)     refresh_postgres; refresh_valkey ;;
esac

echo "Done."
