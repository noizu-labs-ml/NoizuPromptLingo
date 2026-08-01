# syntax=docker/dockerfile:1.7
#
# Cache policy: additive / over-tolerant.
# - npm package cache + .next/cache on BuildKit mounts (partials kept across builds).
# - Prefer occasional prune over cold npm ci / next rebuilds.
ARG NODE_VERSION=22-alpine

FROM node:${NODE_VERSION} AS deps
RUN apk add --no-cache gettext
WORKDIR /app
COPY package.json package-lock.json* .npmrc.template ./
RUN --mount=type=secret,id=npm_token \
    --mount=type=cache,target=/root/.npm,sharing=locked \
    NPM_TOKEN=$(cat /run/secrets/npm_token) \
    envsubst < .npmrc.template > .npmrc && \
    npm ci && \
    rm -f .npmrc

FROM node:${NODE_VERSION} AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_TELEMETRY_DISABLED=1

# Keep Next incremental compile cache across layer misses.
RUN --mount=type=cache,id=npl-mcp-next-cache,target=/app/.next/cache,sharing=locked \
    npm run build

FROM node:${NODE_VERSION} AS production
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
COPY --from=build --chown=nextjs:nodejs /app/src/config ./src/config
COPY --chown=nextjs:nodejs docker-entrypoint.sh ./

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["sh", "docker-entrypoint.sh"]
