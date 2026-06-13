# syntax=docker/dockerfile:1.7
# =============================================================================
# tobornalp.com — Frontend (Next.js 15)
# =============================================================================
# Multi-stage build: deps → build → runtime (standalone output).
# Uses private @the-robot-lives npm registry via build secret.
#
# Build:
#   docker-build tobornalp.com/frontend
#   docker-build tobornalp.com/frontend --native   # fast local build (host arch)
#
# The --native flag skips multiarch. Default is linux/amd64,linux/arm64.
# =============================================================================
ARG NODE_VERSION=22-alpine

# ── Stage 1: Install dependencies ────────────────────────────────────────────
FROM node:${NODE_VERSION} AS build
RUN apk add --no-cache gettext
WORKDIR /app

COPY package.json ./
COPY package-lock.jso[n] ./
COPY .npmrc.template ./

RUN --mount=type=cache,target=/root/.npm \
    --mount=type=secret,id=github_token \
    --mount=type=secret,id=verdaccio_token \
    GITHUB_TOKEN=$(cat /run/secrets/github_token 2>/dev/null || echo "") \
    VERDACCIO_TOKEN=$(cat /run/secrets/verdaccio_token 2>/dev/null || echo "") \
    envsubst < .npmrc.template > .npmrc && \
    ([ -f package-lock.json ] && npm ci || npm install) && \
    rm -f .npmrc

# ── Stage 2: Build ───────────────────────────────────────────────────────────
COPY . .

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN --mount=type=cache,target=/app/.next/cache \
    npm run build

# ── Stage 3: Runtime ─────────────────────────────────────────────────────────
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
COPY --chown=nextjs:nodejs docker-entrypoint.sh ./

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["sh", "docker-entrypoint.sh"]
