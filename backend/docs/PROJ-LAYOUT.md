# Project Layout — backend (NoizuPromptLingua)

Phoenix 1.8 / Elixir OTP app `:noizu_prompt_lingua`. JSON API, JWT + OIDC SSO, 20+ MCP domain servers, Liquibase + Ecto schema dual-track.

```
backend/
├── lib/
│   ├── noizu_prompt_lingua.ex          # App module root
│   ├── noizu_prompt_lingua/            # Core → [layout/lib.md](layout/lib.md)
│   │   ├── application.ex              #   OTP supervisor
│   │   ├── domains/                    #   Business domains + per-domain mcp.ex + tools/
│   │   ├── mcp/                        #   Tenancy MCP (orgs/projects/sessions) + tool_guard
│   │   ├── entities/                   #   Noizu entity layer (users, orgs, authz, …)
│   │   ├── schema/                     #   Ecto schemas
│   │   ├── npl/                        #   Convention engine (load/parse/resolve)
│   │   ├── tools/                      #   Discovery tools + npl_load / npl_spec
│   │   ├── auth/ · authz/ · workers/   #   Auth helpers, PBAC eval, Oban workers
│   │   ├── repo.ex · guardian.ex       #   Ecto repo, JWT
│   │   └── …
│   ├── noizu_prompt_lingua_web.ex
│   ├── noizu_prompt_lingua_web/
│   │   ├── endpoint.ex · router.ex · telemetry.ex
│   │   ├── controllers/                #   REST + MCP gateways + media serve
│   │   ├── plugs/                      #   Auth, CORS, roles, rate limit, mock MCP
│   │   └── channels/                   #   UserSocket, org + browser channels
│   ├── mix/tasks/                      # Custom mix tasks (seed, backfill)
│   └── supports/                       # Shared types, migration helpers, events
├── config/
│   ├── config.exs · dev.exs · test.exs · prod.exs
│   └── runtime.exs                     # Env-var runtime config
├── db/
│   ├── changelog/                      # Liquibase YAML 000–073 + db.changelog-master.yaml
│   ├── liquibase.properties
│   └── Dockerfile                      # Migration runner image
├── priv/
│   ├── conventions/                    # NPL YAML corpus (npl.yaml, directives, …)
│   ├── unicode-codex/global.yaml       # Glyph codex seed
│   ├── repo/                           # Ecto migrations + seeds/
│   ├── skills/content-generator/       # Content-generator skill pack
│   ├── static/downloads/               # Packaged local-mcp / browser / remote-access tarballs
│   └── gettext/
├── test/
│   ├── noizu_prompt_lingua/            # Domain / unit tests
│   ├── noizu_prompt_lingua_web/        # Controller / channel tests
│   ├── support/
│   └── test_helper.exs
├── bin/dev-start.sh
├── docs/
│   ├── PROJ-LAYOUT.md                  # This file
│   ├── PROJ-LAYOUT.summary.md
│   ├── PROJ-ARCH.md · .summary.md
│   ├── layout/lib.md
│   └── mcp-jwt-and-setup-implementation.md
├── vendor/noizu_labs_pm/               # Vendored PM dependency (local path)
├── Dockerfile · Dockerfile.dev
├── mix.exs · mix.lock
└── .env                                # ⚠ configure (make init)
```

## Key files requiring setup

| File | Action |
|------|--------|
| `.env` | DB URL, Guardian secret, Redis, OIDC — from root `make init` |
| `db/liquibase.properties` | Usually OK via compose; host CLI needs DB reachable |

## Mix aliases (typical)

| Command | Purpose |
|---------|---------|
| `mix setup` | deps + ecto create/migrate + seeds |
| `mix test` | Create/migrate test DB + run tests |
| `mix ecto.reset` | Drop → create → migrate → seeds |

## Notable stack

Phoenix 1.8 + Bandit · Guardian JWT · Ueberauth OIDC · Ecto/Postgres (PostGIS, pgvector) · Redix · Oban · Weaviate (tool search / memory) · GenAI · Liquibase changelogs under `db/changelog/`
