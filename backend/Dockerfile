# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE="elixir:1.19.5-otp-28-slim"

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

COPY mix.exs mix.lock ./
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix deps.get --only $MIX_ENV && \
    mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    MIX_OS_DEPS_COMPILE_PARTITION_COUNT=1 mix deps.compile

COPY lib lib
COPY priv priv

RUN --mount=type=cache,target=/root/.hex \
    --mount=type=cache,target=/root/.cache/rebar3 \
    mix compile

COPY config/runtime.exs config/

RUN mix release

FROM ${BASE_IMAGE} AS production

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=build --chown=nobody:root /app/_build/${MIX_ENV}/rel/noizu_prompt_lingua ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || exit 1

CMD ["bin/noizu_prompt_lingua", "start"]
