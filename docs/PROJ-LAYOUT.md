# Project Layout

NoizuPromptLingo — Elixir/Phoenix MCP server + Next.js dashboard for the Tobor platform.

```
NoizuPromptLingo/
├── config/                     # Elixir/Phoenix environment configs
│   ├── config.exs              #   Shared config
│   ├── dev.exs                 #   Dev overrides
│   ├── prod.exs                #   Prod overrides
│   ├── runtime.exs             #   Runtime (env-var driven)
│   └── test.exs                #   Test overrides
├── db/                         # Liquibase database migrations
│   ├── changelog/              #   YAML changelogs (extensions, enums, users, api-keys)
│   ├── Dockerfile              #   Liquibase runner image
│   └── liquibase.properties    #   Connection config
├── design/                     # UI prototypes
├── docs/                       # Documentation
│   ├── tools/                  #   MCP tool reference (per-domain guides)
│   └── layout/                 #   Detailed layout breakdowns
├── helm/                       # Helm chart → [layout/helm.md](layout/helm.md)
│   └── npl-mcp/                #   K8s deployment chart
├── lib/                        # Elixir source → [layout/lib.md](layout/lib.md)
│   ├── noizu_prompt_lingua/    #   Core app (domains, schema, MCP tools, NPL engine)
│   ├── npl_web/                #   Phoenix endpoint, router, controllers
│   ├── noizu_prompt_lingua.ex  #   Top-level module
│   └── npl_web.ex              #   Web module macros
├── nginx/                      # Reverse proxy configs
│   ├── build/                  #   Docker build for nginx image
│   ├── nginx.conf              #   Dev config
│   └── nginx.prod.conf         #   Prod config
├── priv/                       # OTP priv resources
│   ├── conventions/            #   NPL convention YAML definitions
│   ├── repo/migrations/        #   Ecto migrations (21 files, 20260614–20260620)
│   └── skills/                 #   Bundled skill definitions
├── test/                       # ExUnit test suite
│   ├── noizu_prompt_lingua/    #   Domain + schema tests
│   └── support/                #   Test helpers (DataCase)
├── web/                        # Next.js dashboard → [layout/web.md](layout/web.md)
│   ├── app/                    #   App Router pages (dashboard, chat, tickets, reviews, projects)
│   ├── components/             #   Shared React components (sidebar)
│   └── lib/                    #   Client API helpers
├── .dockerignore               # Docker build exclusions
├── .env.example                # Environment variable template — copy to .env
├── .gitignore
├── .tool-versions              # asdf/mise runtime versions
├── docker-compose.yml          # Local dev services (Postgres, app, nginx)
├── Dockerfile                  # → Dockerfile.elixir (symlink)
├── Dockerfile.elixir           # Elixir release build
├── Dockerfile.nextjs           # Next.js dashboard build
├── mix.exs                     # Elixir project definition + dependencies
└── mix.lock                    # Locked dependency versions
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.env` | Copy from `.env.example`, fill database URL + secrets |
| `.tool-versions` | Install runtimes via `asdf install` or `mise install` |
| `db/liquibase.properties` | Configure DB connection for Liquibase migrations |
