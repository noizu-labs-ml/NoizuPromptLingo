# ---- Stage 1: Frontend Build ----
FROM node:22-slim AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN mkdir -p /app/src/npl_mcp/web/static
RUN npm run build

# ---- Stage 2: Python Dependencies ----
FROM python:3.13-slim AS python-deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libcairo2-dev \
    libxml2-dev \
    libxslt1-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# ---- Stage 3: Runtime ----
FROM python:3.13-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libcairo2 \
    libxml2 \
    libxslt1.1 \
    curl \
    && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app

COPY --from=python-deps /app/.venv .venv
COPY --from=frontend-build /app/src/npl_mcp/web/static src/npl_mcp/web/static

COPY pyproject.toml uv.lock ./
COPY src/ src/
COPY conventions/ conventions/
COPY agents/ agents/
COPY project-management/ project-management/
COPY docs/ docs/
COPY npl/ npl/
COPY tools/ tools/
COPY liquibase/ liquibase/
COPY docker/ docker/

RUN uv sync --frozen --no-dev

ENV PATH="/app/.venv/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    NPL_PROJECT=NoizuPromptLingo \
    NPL_DB_HOST=npl-timescaledb \
    NPL_DB_PORT=5432 \
    NPL_DB_NAME=npl \
    NPL_DB_USER=npl \
    NPL_DB_PASSWORD=npl_secret

EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -sf http://localhost:8765/api/health/ping || exit 1

CMD ["npl-mcp", "--host", "0.0.0.0", "--port", "8765"]
