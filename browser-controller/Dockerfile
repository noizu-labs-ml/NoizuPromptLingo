# Headless browser-controller image for running as a server-side pod.
#
# Built on the official Playwright image, which ships the matching chromium
# build and all OS dependencies, so we skip the `playwright install` postinstall
# step (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1). Driven entirely by env vars; runs
# headless by default. Screenshots and videos are streamed straight to MinIO via
# the cloud-minted presigned PUT URLs, so the pod needs no object-store creds.
FROM mcr.microsoft.com/playwright:v1.61.0-jammy

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    BROWSER_CONTROLLER_HEADED=false

WORKDIR /app

# Install dependencies against the lockfile first for layer caching. Dev deps
# (typescript) are needed for the build, so we don't set NODE_ENV=production
# here — `npm ci` would otherwise prune them before `npm run build` runs.
COPY package.json package-lock.json ./
RUN npm ci

# Build the TypeScript controller.
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# Required at runtime (no sensible defaults for a pod):
#   BROWSER_CONTROLLER_URL    cloud socket URL (wss://tobor.locker/socket)
#   BROWSER_CONTROLLER_TOKEN  MCP JWT
#   BROWSER_CONTROLLER_ORG    organization id (UUID)
# Optional:
#   BROWSER_CONTROLLER_HEADED set "true" to launch a headed browser (needs a display)
CMD ["node", "dist/index.js"]
