# syntax=docker/dockerfile:1.7
#
# Cache policy: additive / over-tolerant.
# - npm package cache on BuildKit mount (partials kept across builds).
# - Prefer occasional prune over cold npm ci / rebuilds.
#
# Headless remote-access tunnel client image.
#
# Claims a named tunnel from the cloud (MCP JWT) and runs frpc to expose a local
# port at https://<name>.remote-access.noizu.com. The frpc binary is vendored by
# the postinstall script for linux/amd64 (override with FRPC_BIN). Driven
# entirely by env vars.
FROM node:22-bookworm-slim

# tar is present in the base image; ensure CA certs + tar/unzip for the frpc
# postinstall download.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tar unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies against the lockfile first for layer caching. Dev deps
# (typescript) are needed for the build, so we don't set NODE_ENV=production
# here — `npm ci` would otherwise prune them before `npm run build` runs.
# The postinstall vendors frpc for the image's platform.
COPY package.json package-lock.json ./
COPY scripts ./scripts
RUN --mount=type=cache,id=npl-remote-access-npm,target=/root/.npm,sharing=locked \
    npm ci

# Build the TypeScript client.
COPY tsconfig.json ./
COPY src ./src
RUN --mount=type=cache,id=npl-remote-access-npm,target=/root/.npm,sharing=locked \
    npm run build

# Required at runtime (no sensible defaults for a pod):
#   REMOTE_ACCESS_NAME    subdomain to claim
#   REMOTE_ACCESS_PORT    local port to expose
#   REMOTE_ACCESS_TOKEN   MCP JWT
#   REMOTE_ACCESS_ORG     organization id (UUID)
# Optional:
#   REMOTE_ACCESS_API     NPL API base (default https://tobor.locker)
#   REMOTE_ACCESS_SERVER  frps control host (default tunnel.noizu.com)
#   REMOTE_ACCESS_LOCAL_IP  local bind ip (default 127.0.0.1)
#   FRPC_BIN              path to an frpc binary (skips the vendored one)
CMD ["node", "dist/index.js"]
