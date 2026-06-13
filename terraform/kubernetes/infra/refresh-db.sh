#!/usr/bin/env bash
# Refresh the shared infra databases — re-run init / re-apply users without
# (by default) destroying data.
#
# Background:
#   * Postgres/TimescaleDB only runs /docker-entrypoint-initdb.d scripts when
#     PGDATA is EMPTY. Restarting the pod does NOT re-run init-db.sh, so we exec
#     the (idempotent) script against the live pod instead.
#   * Valkey re-applies its ACL users on every pod start (the `prepare` init
#     container copies the users.acl secret into /data), so a rollout restart is
#     enough to pick up user/password changes.
#
# Usage:
#   ./refresh-db.sh                 # refresh both, keep data (default)
#   ./refresh-db.sh postgres        # only Postgres/Timescale
#   ./refresh-db.sh valkey          # only Valkey
#   ./refresh-db.sh --wipe          # DESTRUCTIVE: delete PVCs + recreate (both)
#   ./refresh-db.sh --wipe postgres # DESTRUCTIVE: wipe only Postgres data
#
# --wipe deletes the data PVC so the next pod comes up fresh; you must run
# `terraform -chdir=infra apply` afterwards to recreate the PVC + roll the pod.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

NS="${NS:-$(terraform -chdir="$HERE/../init" output -raw namespace 2>/dev/null || true)}"
[[ -n "$NS" ]] || { echo "Could not determine namespace; set NS=<namespace>" >&2; exit 1; }

WIPE=0
TARGET="both"
for arg in "$@"; do
  case "$arg" in
    --wipe)            WIPE=1 ;;
    postgres|timescale) TARGET="postgres" ;;
    valkey)            TARGET="valkey" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

echo "Namespace: $NS  |  target: $TARGET  |  wipe: $WIPE"

refresh_postgres() {
  if [[ "$WIPE" == 1 ]]; then
    echo "==> WIPING Postgres/Timescale data (infra-timescaledb-data)"
    kubectl -n "$NS" scale deploy/infra-timescaledb --replicas=0
    kubectl -n "$NS" delete pvc infra-timescaledb-data --ignore-not-found
    echo "    PVC deleted. Run: terraform -chdir=$HERE apply"
  else
    echo "==> Re-running init-db.sh on infra-timescaledb (idempotent, keeps data)"
    kubectl -n "$NS" exec deploy/infra-timescaledb -c timescaledb -- \
      bash /docker-entrypoint-initdb.d/init-db.sh
  fi
}

refresh_valkey() {
  if [[ "$WIPE" == 1 ]]; then
    echo "==> WIPING Valkey data (infra-valkey-data)"
    kubectl -n "$NS" scale deploy/infra-valkey --replicas=0
    kubectl -n "$NS" delete pvc infra-valkey-data --ignore-not-found
    echo "    PVC deleted. Run: terraform -chdir=$HERE apply"
  else
    echo "==> Rolling infra-valkey to re-apply ACL users (keeps data)"
    kubectl -n "$NS" rollout restart deploy/infra-valkey
    kubectl -n "$NS" rollout status  deploy/infra-valkey --timeout=120s
  fi
}

case "$TARGET" in
  postgres) refresh_postgres ;;
  valkey)   refresh_valkey ;;
  both)     refresh_postgres; refresh_valkey ;;
esac

echo "Done."
