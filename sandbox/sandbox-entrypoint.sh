#!/usr/bin/env bash
set -uo pipefail

# Live-sandbox entrypoint.
# Fast spin-up: skip mix deps.get / npm install when lock stamps match existing trees.

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    cat "$@" 2>/dev/null | sha256sum | awk '{print $1}'
  else
    cat "$@" 2>/dev/null | shasum -a 256 | awk '{print $1}'
  fi
}

# When called without arguments, seed workspace + launch supervisor.
# When called with "frontend" or "backend", run that dev server (used by supervisor).

case "${1:-}" in
  frontend)
    export HOME=/home/dev
    cd /workspace/frontend
    if [ ! -f package.json ]; then
      echo "[sandbox:frontend] No package.json — waiting for source files..."
      while [ ! -f package.json ]; do sleep 2; done
    fi
    # In-cluster: use internal verdaccio; outside: use npm.noizu.com with token
    if [ -n "${NPM_TOKEN:-}" ]; then
      if [ -f .npmrc.template ]; then
        envsubst < .npmrc.template > .npmrc
      fi
    elif [ -n "${NPM_REGISTRY_INTERNAL:-}" ]; then
      echo "@noizu:registry=${NPM_REGISTRY_INTERNAL}" > .npmrc
    fi

    STAMP="node_modules/.spinup-lock-stamp"
    CUR="$(hash_file package.json package-lock.json)"
    NEED_INSTALL=1
    DID_INSTALL=0
    if [ -n "$CUR" ] && [ -d node_modules ] && [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$CUR" ]; then
      if [ -f node_modules/.bin/next ] || [ -d node_modules/next ]; then
        NEED_INSTALL=0
      fi
    fi
    if [ "$NEED_INSTALL" -eq 1 ]; then
      echo "[sandbox:frontend] npm install (cold or lock changed)"
      npm install --prefer-offline 2>&1 || npm install --force 2>&1 || true
      mkdir -p node_modules
      printf '%s\n' "$CUR" >"$STAMP" 2>/dev/null || true
      DID_INSTALL=1
    else
      echo "[sandbox:frontend] npm deps warm — skip install"
    fi
    if [ "$DID_INSTALL" -eq 1 ] || [ "${FORCE_REGEN:-0}" = "1" ]; then
      npm run --silent regen 2>/dev/null || true
    fi
    exec npx next dev
    ;;

  backend)
    export HOME=/home/dev
    export MIX_HOME=/home/dev/.mix
    export HEX_HOME=/home/dev/.hex
    cd /workspace/backend
    if [ ! -f mix.exs ]; then
      echo "[sandbox:backend] No mix.exs — waiting for source files..."
      while [ ! -f mix.exs ]; do sleep 2; done
    fi
    export MIX_ENV=dev
    mix local.hex --force --if-missing
    mix local.rebar --force --if-missing

    STAMP="deps/.spinup-lock-stamp"
    CUR="$(hash_file mix.exs mix.lock)"
    NEED_GET=1
    if [ -n "$CUR" ] && [ -d deps ] && [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$CUR" ]; then
      if [ -n "$(ls -A deps 2>/dev/null | grep -v '^\.spinup' || true)" ]; then
        NEED_GET=0
      fi
    fi
    if [ "$NEED_GET" -eq 1 ]; then
      echo "[sandbox:backend] mix deps.get (cold or lock changed)"
      mix deps.get
      mkdir -p deps
      printf '%s\n' "$CUR" >"$STAMP" 2>/dev/null || true
    else
      echo "[sandbox:backend] mix deps warm — skip deps.get"
    fi

    mix ecto.create 2>/dev/null || true
    mix ecto.migrate 2>/dev/null || true
    exec mix phx.server
    ;;

  *)
    # Main entrypoint: seed workspace, start supervisor (samba only),
    # then start dev servers after source is in place.
    mkdir -p /workspace/frontend /workspace/backend

    # Only chown after seed or when workspace root is not owned by dev.
    # Unconditional chown -R over warm deps/node_modules/_build is a major spin-up tax.
    SEEDED=0
    if [ -d /seed/frontend ] && [ ! -f /workspace/frontend/package.json ]; then
      echo "[sandbox] Seeding frontend source..."
      cp -a /seed/frontend/. /workspace/frontend/
      SEEDED=1
    fi
    if [ -d /seed/backend ] && [ ! -f /workspace/backend/mix.exs ]; then
      echo "[sandbox] Seeding backend source..."
      cp -a /seed/backend/. /workspace/backend/
      SEEDED=1
    fi
    if [ "$SEEDED" -eq 1 ]; then
      echo "[sandbox] chown after seed"
      chown -R dev:dev /workspace
    elif [ "$(stat -c '%U' /workspace 2>/dev/null || stat -f '%Su' /workspace 2>/dev/null || echo dev)" != "dev" ]; then
      echo "[sandbox] chown workspace root (owner mismatch)"
      chown -R dev:dev /workspace
    else
      echo "[sandbox] skip chown (warm workspace)"
    fi

    mkdir -p /var/log/samba /var/log/supervisor

    # Start supervisor (samba only — frontend/backend are autostart=false)
    /usr/bin/supervisord -c /etc/supervisor/conf.d/sandbox.conf &
    SUPERVISOR_PID=$!
    # Brief settle for supervisord socket (was 2s; 0.5s is enough on warm hosts)
    sleep 0.5

    # Now start dev servers via supervisor
    if [ -f /workspace/frontend/package.json ]; then
      supervisorctl -c /etc/supervisor/conf.d/sandbox.conf start frontend
    else
      echo "[sandbox] No frontend source found — mount files via Samba, then run: supervisorctl start frontend"
    fi
    if [ -f /workspace/backend/mix.exs ]; then
      supervisorctl -c /etc/supervisor/conf.d/sandbox.conf start backend
    else
      echo "[sandbox] No backend source found — mount files via Samba, then run: supervisorctl start backend"
    fi

    echo "[sandbox] Ready. Samba share at //container:445/workspace (user: dev / pass: dev)"
    wait $SUPERVISOR_PID
    ;;
esac
