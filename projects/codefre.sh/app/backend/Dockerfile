# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE="elixir:1.19.5-otp-28-slim"

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

# Install the Hex/rebar archives into the image (NOT a cache mount) so every
# subsequent `mix` invocation can find them. Only the Hex *package* cache at
# /root/.hex is eligible for --mount=type=cache; /root/.mix holds the archive
# install and must persist in the image layer.
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

FROM ${BASE_IMAGE} AS production

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=build --chown=nobody:root /app/_build/${MIX_ENV}/rel/codefresh ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || exit 1

CMD ["bin/codefresh", "start"]
