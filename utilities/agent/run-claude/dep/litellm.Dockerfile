# =============================================================================
# run-claude LiteLLM Proxy Container
# =============================================================================
# Custom image with litellm[proxy], prisma, and all required dependencies.
# Build: docker build -f dep/litellm.Dockerfile -t run-claude-litellm:latest .
# =============================================================================

FROM python:3.13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc g++ libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install LiteLLM + dependencies
RUN pip install --no-cache-dir \
    'litellm[proxy]' \
    litellm-proxy-extras \
    psycopg2-binary \
    'prisma==0.11.0' \
    prometheus_client \
    pyyaml

# Generate Prisma client during build (requires a dummy DATABASE_URL)
# litellm-proxy-extras provides schema.prisma; litellm also bundles one
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" \
    prisma generate --schema=/usr/local/lib/python3.13/site-packages/litellm/proxy/schema.prisma

# Config directory (mounted at runtime)
RUN mkdir -p /app/config

ENV PYTHONPATH="/app:${PYTHONPATH}"
ENV STORE_MODEL_IN_DB="True"
ENV USE_PRISMA_MIGRATE="True"

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -sf -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" http://localhost:4444/health || exit 1

EXPOSE 4444

ENTRYPOINT ["litellm"]
CMD ["--host", "0.0.0.0", "--port", "4444", "--config", "/app/config/litellm_config.yaml"]
