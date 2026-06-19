#!/usr/bin/env bash
set -uo pipefail

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
    npm install --prefer-offline 2>&1 || npm install --force 2>&1 || true
    npm run --silent regen 2>/dev/null || true
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
    mix deps.get
    mix ecto.create 2>/dev/null || true
    mix ecto.migrate 2>/dev/null || true
    exec mix phx.server
    ;;

  *)
    # Main entrypoint: seed workspace, start supervisor (samba only),
    # then start dev servers after source is in place.
    mkdir -p /workspace/frontend /workspace/backend

    if [ -d /seed/frontend ] && [ ! -f /workspace/frontend/package.json ]; then
      echo "[sandbox] Seeding frontend source..."
      cp -a /seed/frontend/. /workspace/frontend/
    fi
    if [ -d /seed/backend ] && [ ! -f /workspace/backend/mix.exs ]; then
      echo "[sandbox] Seeding backend source..."
      cp -a /seed/backend/. /workspace/backend/
    fi
    chown -R dev:dev /workspace

    mkdir -p /var/log/samba /var/log/supervisor

    # Start supervisor (samba only — frontend/backend are autostart=false)
    /usr/bin/supervisord -c /etc/supervisor/conf.d/sandbox.conf &
    SUPERVISOR_PID=$!
    sleep 2

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
