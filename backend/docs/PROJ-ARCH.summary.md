# Architecture Summary

Phoenix 1.8 JSON API (Elixir 1.19 / OTP 28) with Bandit HTTP server.

**Auth:** Guardian JWT — access tokens (1h) + refresh tokens (7d), bcrypt password hashing.

**Data:** PostgreSQL with UUID PKs, PostGIS, pgvector. Custom Postgrex types module.

**Supervision tree:** Telemetry → Repo → Migrator → DNSCluster → PubSub → Endpoint.

**Routes:** Public `/health`, `/api/v1/auth/{register,login,refresh}`. Protected `/api/v1/auth/me` via Bearer token pipeline.

**Provisioned but not yet wired:** GenAI (LLM), Syn (process registry), Redix (Redis), Noizu Labs Entities.

**Deployment:** Multi-stage Docker, OTP release, health check on `/health`. Requires `DATABASE_URL`, `SECRET_KEY_BASE`, `GUARDIAN_SECRET_KEY`.
