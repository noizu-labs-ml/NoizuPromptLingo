#!/usr/bin/env bash
# Fast spin-up for local/compose frontend dev.
# Skips `npm install` when package.json+lock hash matches stamp in node_modules/.
set -euo pipefail

cd "$(dirname "$0")/.."

hash_npm() {
  # shellcheck disable=SC2046
  if command -v sha256sum >/dev/null 2>&1; then
    cat package.json package-lock.json yarn.lock 2>/dev/null | sha256sum | awk '{print $1}'
  else
    cat package.json package-lock.json yarn.lock 2>/dev/null | shasum -a 256 | awk '{print $1}'
  fi
}

# Auth / registry (compose + sandbox)
if [ -n "${NPM_TOKEN:-}" ] && [ -f .npmrc.template ]; then
  # shellcheck disable=SC2016
  if command -v envsubst >/dev/null 2>&1; then
    # Support either GITHUB_TOKEN or NPM_TOKEN in templates
    export GITHUB_TOKEN="${GITHUB_TOKEN:-${NPM_TOKEN:-}}"
    export NPM_TOKEN="${NPM_TOKEN:-}"
    envsubst < .npmrc.template > .npmrc
  fi
elif [ -n "${NPM_REGISTRY_INTERNAL:-}" ]; then
  echo "@noizu:registry=${NPM_REGISTRY_INTERNAL}" > .npmrc
fi

STAMP="node_modules/.spinup-lock-stamp"
CUR="$(hash_npm)"
NEED_INSTALL=1
DID_INSTALL=0

if [ -n "$CUR" ] && [ -d node_modules ] && [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$CUR" ]; then
  if [ -f node_modules/.bin/next ] || [ -d node_modules/next ]; then
    NEED_INSTALL=0
  fi
fi

if [ "$NEED_INSTALL" -eq 1 ]; then
  echo "[dev-start] npm install (cold or lock changed)"
  npm install --prefer-offline 2>&1 || npm install 2>&1
  mkdir -p node_modules
  printf '%s\n' "$CUR" >"$STAMP"
  DID_INSTALL=1
else
  echo "[dev-start] npm deps warm — skip install"
fi

# regen only after install or when forced (codegen from packages)
if [ "$DID_INSTALL" -eq 1 ] || [ "${FORCE_REGEN:-0}" = "1" ]; then
  npm run --silent regen 2>/dev/null || true
fi

exec npm run dev
