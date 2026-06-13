# syntax=docker/dockerfile:1.7
# =============================================================================
# tobornalp.com — Backend (Phoenix 1.8 / Elixir)
# =============================================================================
# Multi-stage build: deps → compile → release → runtime.
# Cross-arch safe (QEMU/Rosetta JIT workaround via +JMsingle).
#
# Build:
#   docker-build tobornalp.com/backend
#   docker-build tobornalp.com/backend --native   # fast local build (host arch)
# =============================================================================
ARG BASE_IMAGE="elixir:1.19.5-otp-28-slim"

# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM ${BASE_IMAGE} AS build

RUN apt-get update -y && \
    apt-get install -y build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cross-arch emulation (QEMU / Rosetta) breaks BEAM's double-mapped RWX JIT
# pages and corrupts the compiler's module table mid-deps.compile — surfaces
# as spurious "<Module> is already compiled" errors. See
# https://github.com/elixir-lang/elixir/issues/13669 (José Valim).
# +JMsingle true → single-mapped RWX, emulation-friendly. Harmless on native.
ENV ERL_AFLAGS="+JMsingle true"

# Cap BEAM scheduler count during build — under cross-arch QEMU emulation each
# scheduler's RSS is amplified and mix deps.compile can OOM the build VM.
ENV ERL_FLAGS="+S 2:2"
ENV ELIXIR_ERL_OPTIONS="+S 2:2"

# Install Hex/rebar archives into the image (NOT a cache mount) so every
# subsequent `mix` invocation can find them.
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs ./
COPY mix.loc[k] ./
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix deps.get --only $MIX_ENV && \
    mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix deps.compile

COPY lib lib
COPY priv priv

COPY config/runtime.exs config/

RUN mix release

# ── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM ${BASE_IMAGE} AS production

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=build --chown=nobody:root /app/_build/${MIX_ENV}/rel/tobornalp ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/api/health || exit 1

CMD ["bin/tobornalp", "start"]
