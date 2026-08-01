#!/usr/bin/env bash
# Staging ETL: tobor_locker + therobotplans → pm_core (shared schema).
# Does NOT set PM_CORE_ENABLED on apps. Re-runnable (ON CONFLICT DO NOTHING).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
NS="${NS:-apps}"
LOCAL="${LOCAL_PORT:-54354}"

echo "==> Port-forward app-timescaledb → localhost:${LOCAL}"
pkill -f "port-forward.*${LOCAL}:5432" 2>/dev/null || true
kubectl -n "$NS" port-forward "svc/app-timescaledb" "${LOCAL}:5432" >/tmp/pf-etl-run.log 2>&1 &
PF=$!
cleanup() { kill "$PF" 2>/dev/null || true; }
trap cleanup EXIT

for _ in $(seq 1 40); do
  nc -z 127.0.0.1 "$LOCAL" 2>/dev/null && break
  sleep 0.25
done

ADMIN_USER=$(kubectl -n "$NS" get secret app-timescaledb-secrets -o jsonpath='{.data.POSTGRES_USER}' | base64 -d)
export PGPASSWORD=$(kubectl -n "$NS" get secret app-timescaledb-secrets -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d)

sql() {
  local db="$1"; shift
  docker run --rm --add-host=host.docker.internal:host-gateway \
    -e PGPASSWORD \
    -v "$ROOT:/etl:ro" \
    postgres:16-alpine \
    psql -h host.docker.internal -p "$LOCAL" -U "$ADMIN_USER" -d "$db" -v ON_ERROR_STOP=1 "$@"
}

# dblink to sibling DBs on same postgres instance (unix socket path not available
# from docker; use host connection via localhost inside server? Use dbname-only
# which works when connected as superuser on same cluster.)
# From inside the server, dblink to sibling: host is not needed when using
# libpq defaults if we connect to pm_core as postgres on the forwarded port —
# but dblink runs *on the server*, so conninfo is server-local:
TRP_CONN="dbname=therobotplans user=${ADMIN_USER} password=${PGPASSWORD}"
NPL_CONN="dbname=tobor_locker user=${ADMIN_USER} password=${PGPASSWORD}"

echo "==> Ensure dblink"
sql pm_core -c "CREATE EXTENSION IF NOT EXISTS dblink;"

echo "==> ID maps"
sql pm_core -f /etl/00_id_maps.sql

echo "==> Load shared tables"
sql pm_core \
  -v trp_conn="$TRP_CONN" \
  -v npl_conn="$NPL_CONN" \
  -f /etl/10_load_trp_and_npl.sql

echo "==> Load PBAC groups + scoped_memberships"
sql pm_core \
  -v trp_conn="$TRP_CONN" \
  -v npl_conn="$NPL_CONN" \
  -f /etl/11_load_pbac.sql

echo "==> Sample orgs / items / memberships"
sql pm_core -c "SELECT slug FROM organizations ORDER BY slug;"
sql pm_core -c "SELECT item_type, count(*) FROM items GROUP BY 1 ORDER BY 2 DESC;"
sql pm_core -c "SELECT name::text, count(*) FROM groups g LEFT JOIN scoped_memberships s ON s.group_id=g.id GROUP BY 1 ORDER BY 1;"

echo "==> ETL complete (apps still on legacy DBs)"
unset PGPASSWORD
