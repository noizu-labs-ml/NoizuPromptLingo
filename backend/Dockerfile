# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE="elixir:1.19.5-otp-28-slim"

# ── Build stage ──────────────────────────────────────────────────
FROM ${BASE_IMAGE} AS build

RUN apt-get update -y && \
    apt-get install -y build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cross-arch emulation (QEMU / Rosetta) breaks BEAM's double-mapped RWX JIT
# pages and can corrupt compiler state during mix deps.compile.
ENV ERL_AFLAGS="+JMsingle true"

# Keep emulated builds below the scheduler/RSS cliff.
ENV ERL_FLAGS="+S 2:2"
ENV ELIXIR_ERL_OPTIONS="+S 2:2"

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Deps first (layer cache)
COPY mix.exs mix.lock ./
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix deps.get --only $MIX_ENV && \
    mkdir config

# Copy compile-time config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix deps.compile

# Copy application code
COPY lib lib
COPY priv priv

RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix compile

# Runtime config needed in the release
COPY config/runtime.exs config/

# Build release
RUN mix release

# ── Runtime stage ────────────────────────────────────────────────
FROM ${BASE_IMAGE} AS production

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=build --chown=nobody:root /app/_build/${MIX_ENV}/rel/boe ./

USER nobody

# ── Environment variables (injected by K8s) ──────────────────────
# DATABASE_URL=ecto://boe:password@db-host:5432/blade_of_eternity_prod
# REDIS_URL=redis://boe:password@redis-host:6379
# SECRET_KEY_BASE=<generated>
# GUARDIAN_SECRET_KEY=<generated>
# PHX_HOST=bladeofeternity.com
# PHX_SERVER=true
# PORT=4000

EXPOSE 4000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/api/health || exit 1

CMD ["bin/boe", "start"]
