ARG NODE_VERSION=22-alpine

# ── Dependencies stage ───────────────────────────────────────────
FROM node:${NODE_VERSION} AS deps

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ── Build stage ──────────────────────────────────────────────────
FROM node:${NODE_VERSION} AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Build-time env vars (baked into the bundle)
# Runtime env vars are read via next.config.ts serverRuntimeConfig
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN npm run build

# ── Runtime stage ────────────────────────────────────────────────
FROM node:${NODE_VERSION} AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy standalone server + static assets
COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public

USER nextjs

# ── Environment variables (injected by K8s) ──────────────────────
# NEXT_PUBLIC_API_URL=https://api.bladeofeternity.com
# Any server-side env vars needed at runtime

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
