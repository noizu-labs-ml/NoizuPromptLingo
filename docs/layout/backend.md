# Backend Layout — Elixir Phoenix API

OTP app `:noizu_prompt_lingua` (`backend/`): Phoenix API serving REST + MCP (StreamableHTTP / WebSocket) behind nginx. PostgreSQL via Ecto; schema owned by Liquibase (`../liquibase/`), Ecto migrations minimal. Redis for cache/pubsub. Guardian (JWT) auth + OAuth clients + SpiceDB-style authz. TRP client for PM integration. Background jobs via Oban.

```
backend/
├── lib/
│   ├── noizu_prompt_lingua/            # Domain core
│   │   ├── domains/                    # Bounded contexts (see below)
│   │   ├── entities/                   # Ecto schemas: users, organizations, projects, sessions, auth/authz, clients, mcp_api_keys, media, versioned
│   │   ├── schema/                     # Shared embedded schemas
│   │   ├── services/                   # Cross-cutting services (attach, comment, watch)
│   │   ├── acl/ · auth/ · authz/       # Access control, Guardian auth, policy layer
│   │   ├── mcp/                        # MCP server implementation (tools, prompts, resources, sockets, custom scopes, endpoint templates)
│   │   ├── trp/                        # TRP (therobotplans) client: transport, provisioning, service auth, cache
│   │   ├── github/                     # GitHub App integration
│   │   ├── media/                      # Media handling
│   │   ├── npl.ex                      # NPL convention domain
│   │   ├── events.ex + events/         # PubSub event bus
│   │   ├── workers/                    # Oban job workers
│   │   ├── protocols/ · oauth/         # Protocols, OAuth provider flows
│   │   ├── cache.ex · redis.ex         # Cache + Redis wiring
│   │   ├── repo.ex · entity_repo.ex    # Ecto repos
│   │   ├── application.ex · release.ex # OTP supervision + release tasks
│   │   └── feature_flags.ex            # Feature flag plumbing
│   ├── noizu_prompt_lingua_web/        # Web layer: router.ex, controllers/, channels/, plugs/, endpoint.ex, telemetry.ex, mcp_config.ex
│   ├── supports/                       # Shared support (ecto helpers, event, migration, types)
│   └── mix/                            # Mix install hooks
├── config/                             # config.exs, dev.exs, prod.exs, runtime.exs, test.exs
├── priv/
│   ├── repo/migrations/                # Minimal Ecto migrations (oban, MCP scopes/keys/toolsets, SSO claims, clients)
│   ├── spicedb/                        # SpiceDB/permission schema definitions
│   ├── conventions/ · skills/ · components/ · unicode-codex/  # Bundled NPL data assets
│   ├── static/                         # Served assets incl. packaged downloads
│   └── w8_*_definitions.exs            # W8 (TRP interop) export/import definitions
├── db/                                 # Liquibase runner context: changelog/, Dockerfile, liquibase.properties
├── vendor/                             # Vendored deps
├── bin/dev-start.sh                    # Local dev bootstrap
├── scripts/                            # Backend maintenance scripts
├── test/                               # ExUnit suites
├── docs/                               # Backend-scoped docs (PROJ-LAYOUT.md, layout/)
├── Dockerfile · Dockerfile.dev         # Container builds
└── mix.exs · mix.lock                  # Mix project definition + lock
```

## Domains (`lib/noizu_prompt_lingua/domains/`)

artifacts · assets · browser · campaigns · chat · customers · dashboard · github · instructions · links · markdown · market · marketing · mcp_overview · memory · mock_mcp · notifications · personas · pubsub · remote_access · review · tickets · unicode_codex · wiki

Each domain folder groups context schemas + logic; `*_web` controllers and MCP tools bind onto them.
