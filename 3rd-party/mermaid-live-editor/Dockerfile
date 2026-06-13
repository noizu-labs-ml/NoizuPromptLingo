FROM docker.io/library/node:22.15.0-alpine3.21 AS mermaid-live-editor-dependencies

RUN apk --no-cache add build-base git python3 && \
    rm -rf /var/cache/apk/*

RUN corepack enable pnpm

WORKDIR /app

COPY ./package.json .
COPY ./pnpm-lock.yaml .

RUN pnpm install

FROM mermaid-live-editor-dependencies AS mermaid-live-editor-builder

ARG MERMAID_RENDERER_URL
ARG MERMAID_KROKI_RENDERER_URL
ARG MERMAID_ANALYTICS_URL
ARG MERMAID_DOMAIN
ARG MERMAID_IS_ENABLED_MERMAID_CHART_LINKS
ARG MERMAID_PRIVACY_POLICY_URL
ARG MERMAID_HIDE_PRIVACY_POLICY
ARG MERMAID_BASE_PATH

COPY . ./

RUN GOGC=off GOMAXPROCS=1 NODE_OPTIONS=--max-old-space-size=4096 pnpm build

FROM mermaid-live-editor-builder AS dev

ENTRYPOINT ["pnpm", "dev"]

FROM docker.io/library/node:22.15.0-alpine3.21 AS production

WORKDIR /app

COPY --from=mermaid-live-editor-builder /app/build ./build
COPY --from=mermaid-live-editor-builder /app/package.json .
COPY --from=mermaid-live-editor-builder /app/node_modules ./node_modules

ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080

CMD ["node", "build/index.js"]
