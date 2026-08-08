# syntax=docker/dockerfile:1.7
#
# Cache policy: additive / over-tolerant.
# - Hex, rebar, deps/, and _build/ live on BuildKit cache mounts with stable IDs.
# - Layer misses still reuse previously compiled beams (partials kept).
# - Prefer occasional `docker buildx prune` over forcing cold recompiles.
# - Release is copied out of the cache mount so the image layer has the artifact.
# - Cache IDs MUST include TARGETARCH — multiarch builds share the builder; a
#   single npl-mcp-mix-build id lets arm64 erlexec leak into the amd64 image
#   (Exec format error on cluster).
ARG BASE_IMAGE="elixir:1.19.5-otp-28-slim"

FROM ${BASE_IMAGE} AS build

# Automatic platform args from BuildKit (used in cache mount ids).
ARG TARGETARCH

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

# Per-arch cache IDs (amd64 vs arm64 must not share _build/deps beams/erts).
# sharing=locked: one compile at a time per cache (avoids concurrent corruption).
COPY mix.exs mix.lock ./
# Path-dep for shared pm_core layer (required before mix deps.get).
COPY vendor/noizu_labs_pm vendor/noizu_labs_pm
RUN --mount=type=cache,target=/root/.hex,sharing=locked \
    --mount=type=cache,target=/root/.cache/rebar3,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-deps-${TARGETARCH},target=/app/deps,sharing=locked \
    mix deps.get --only $MIX_ENV && \
    mkdir -p config

COPY config/config.exs config/${MIX_ENV}.exs config/
# deps.compile: even if this RUN layer misses, _build + deps mounts restore beams.
# Each mix RUN below re-runs deps.get first: in CI (gha layer cache) a layer
# can HIT while the cache mounts arrive empty on a fresh runner — deps.get is
# a ~1s no-op when mounts are warm and repopulates them when they are not.
RUN --mount=type=cache,target=/root/.hex,sharing=locked \
    --mount=type=cache,target=/root/.cache/rebar3,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-deps-${TARGETARCH},target=/app/deps,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-build-${TARGETARCH},target=/app/_build,sharing=locked \
    mix deps.get --only $MIX_ENV && \
    MIX_OS_DEPS_COMPILE_PARTITION_COUNT=1 mix deps.compile

COPY lib lib
COPY priv priv

RUN --mount=type=cache,target=/root/.hex,sharing=locked \
    --mount=type=cache,target=/root/.cache/rebar3,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-deps-${TARGETARCH},target=/app/deps,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-build-${TARGETARCH},target=/app/_build,sharing=locked \
    mix deps.get --only $MIX_ENV && mix compile

COPY config/runtime.exs config/

# Cache mounts are not in the image — materialize the release into a normal path.
# --overwrite: noninteractive; avoids hanging on "Release already exists".
RUN --mount=type=cache,target=/root/.hex,sharing=locked \
    --mount=type=cache,target=/root/.cache/rebar3,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-deps-${TARGETARCH},target=/app/deps,sharing=locked \
    --mount=type=cache,id=npl-mcp-mix-build-${TARGETARCH},target=/app/_build,sharing=locked \
    mix deps.get --only $MIX_ENV && mix release --overwrite && \
    cp -a /app/_build/${MIX_ENV}/rel/noizu_prompt_lingua /app/release && \
    file /app/release/erts-*/bin/erlexec || true

FROM ${BASE_IMAGE} AS production

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=build --chown=nobody:root /app/release ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || exit 1

CMD ["bin/noizu_prompt_lingua", "start"]
