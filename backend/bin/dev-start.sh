#!/usr/bin/env bash
# Fast spin-up for local/compose dev.
# Skips `mix deps.get` when mix.lock+mix.exs hash matches stamp in deps/ (named volume).
set -euo pipefail

cd "$(dirname "$0")/.."

hash_mix() {
  # Prefer sha256sum (Linux containers); fall back to shasum (macOS host runs).
  if command -v sha256sum >/dev/null 2>&1; then
    cat mix.exs mix.lock 2>/dev/null | sha256sum | awk '{print $1}'
  else
    cat mix.exs mix.lock 2>/dev/null | shasum -a 256 | awk '{print $1}'
  fi
}

STAMP="deps/.spinup-lock-stamp"
CUR="$(hash_mix)"
NEED_GET=1

if [ -n "$CUR" ] && [ -d deps ] && [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$CUR" ]; then
  # Ensure at least one dep path exists (empty volume after prune).
  if [ -n "$(ls -A deps 2>/dev/null | grep -v '^\.spinup' || true)" ]; then
    NEED_GET=0
  fi
fi

if [ "$NEED_GET" -eq 1 ]; then
  echo "[dev-start] mix deps.get (cold or lock changed)"
  mix deps.get
  mkdir -p deps
  printf '%s\n' "$CUR" >"$STAMP"
else
  echo "[dev-start] mix deps warm — skip deps.get"
fi

if [ "${SKIP_ECTO:-0}" != "1" ]; then
  if [ "${ECTO_CREATE:-0}" = "1" ]; then
    mix ecto.create 2>/dev/null || true
  fi
  mix ecto.migrate 2>/dev/null || true
fi

# Override for apps that use a non-phx entry (e.g. timely: DEV_SERVER="mix holo")
if [ -n "${DEV_SERVER:-}" ]; then
  # shellcheck disable=SC2086
  exec ${DEV_SERVER}
fi
exec mix phx.server
