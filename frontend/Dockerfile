ARG NODE_VERSION=22-alpine

# ── build-time deps (native) ────────────────────────────────────────────────
# Full dependency tree (incl. devDeps) for the compile. Runs on the BUILD
# host's native arch so @next/swc-* and @tailwindcss/oxide-* execute natively
# — never under QEMU.
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION} AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN --mount=type=secret,id=npmrc,target=/app/.npmrc \
    --mount=type=cache,target=/root/.npm \
    npm ci

# ── server build (native) ───────────────────────────────────────────────────
# Produces the Next.js "standalone" server — pure, arch-independent JS. The
# bundled (build-arch) node_modules is stripped here so the per-arch runtime
# deps below are the single source of the runtime module tree.
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION} AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN npm run build && rm -rf .next/standalone/node_modules

# ── runtime deps (per TARGET arch) ──────────────────────────────────────────
# Independent lib fetch for the image's actual arch — prod deps only. This is
# the only stage that runs under emulation for a cross build, and it's just a
# download + light postinstall, not the heavy webpack/SWC compile.
FROM node:${NODE_VERSION} AS deps-runtime
WORKDIR /app
COPY package.json package-lock.json* ./
RUN --mount=type=secret,id=npmrc,target=/app/.npmrc \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# ── production (per TARGET arch) ─────────────────────────────────────────────
FROM node:${NODE_VERSION} AS production
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Correct-arch runtime module tree (fetched, not copied from the native build).
COPY --from=deps-runtime --chown=nextjs:nodejs /app/node_modules ./node_modules
# Natively-built, arch-independent server (node_modules already stripped above).
COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
# /styleguide reads src/config/theme-style-guide/*.yaml at runtime via
# process.cwd() (see src/app/styleguide/page.tsx). Next.js "standalone" output
# does not trace these fs reads, so copy them into the image explicitly.
COPY --from=build --chown=nextjs:nodejs /app/src/config/theme-style-guide ./src/config/theme-style-guide
COPY --chown=nextjs:nodejs docker-entrypoint.sh ./

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["sh", "docker-entrypoint.sh"]
