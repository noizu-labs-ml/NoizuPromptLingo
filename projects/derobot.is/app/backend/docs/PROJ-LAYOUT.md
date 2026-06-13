# Project Layout — derobot.is/backend

Phoenix 1.8 API backend — Elixir app named `Derobot`.

```
backend/
├── lib/
│   ├── derobot.ex                      # Top-level Derobot module
│   ├── derobot/
│   │   ├── application.ex              # OTP application supervisor
│   │   ├── repo.ex                     # Ecto repo (Postgres)
│   │   ├── accounts.ex                 # Accounts context (user CRUD, auth)
│   │   ├── accounts/
│   │   │   └── user.ex                 # User schema + changeset
│   │   └── guardian.ex                 # Guardian JWT config
│   ├── derobot_web.ex                  # Web module helpers (controller, router macros)
│   ├── derobot_web/
│   │   ├── endpoint.ex                 # HTTP endpoint (Bandit)
│   │   ├── router.ex                   # Route definitions
│   │   ├── telemetry.ex                # Telemetry event handlers
│   │   ├── controllers/
│   │   │   ├── auth_controller.ex      # Register / login / me endpoints
│   │   │   ├── health_controller.ex    # Health check endpoint
│   │   │   └── error_json.ex           # Error response formatting
│   │   └── plugs/
│   │       ├── auth_pipeline.ex        # Guardian auth pipeline plug
│   │       ├── auth_error_handler.ex   # 401 handler for auth failures
│   │       └── cors.ex                 # CORS plug
│   └── supports/
│       └── types.ex                    # Shared type definitions
├── config/
│   ├── config.exs                      # Base config (all envs)
│   ├── dev.exs                         # Dev environment config
│   ├── test.exs                        # Test environment config
│   ├── prod.exs                        # Production config
│   └── runtime.exs                     # Runtime config (env vars)
├── priv/
│   └── repo/
│       ├── migrations/                 # Ecto migrations
│       │   ├── 20260101000000_create_users.exs
│       │   └── 20260101000001_create_seed_helper_tables.exs
│       ├── seeds.exs                   # Seed runner (dispatches by env)
│       └── seeds/
│           ├── dev-seeds.exs           # Dev seed data
│           ├── prod-seeds.exs          # Prod seed data
│           └── test-seeds.exs          # Test seed data
├── test/
│   ├── test_helper.exs                 # Test bootstrap
│   └── support/
│       ├── conn_case.ex                # Shared test case for controllers
│       └── data_case.ex                # Shared test case for data layer
├── docs/
│   ├── PROJ-ARCH.md                    # Architecture document
│   ├── PROJ-ARCH.summary.md            # Architecture summary
│   ├── PROJ-LAYOUT.md                  # This file
│   └── PROJ-LAYOUT.summary.md          # Tree-only quick reference
├── .tool-versions                      # asdf versions (Elixir 1.19, Erlang 28, cmake)
├── .formatter.exs                      # Elixir formatter config
├── .gitignore                          # Git ignore rules
├── .dockerignore                       # Docker ignore rules
├── Dockerfile                          # Production container build
├── Dockerfile.dev                      # Development container build
├── mix.exs                             # Project definition + dependencies
└── mix.lock                            # Locked dependency versions
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.env` | Configure database URL, Guardian secret, etc. |
| `.tool-versions` | Run `asdf install` to match Elixir/Erlang/cmake versions |

## Mix Aliases

| Command | Purpose |
|---------|---------|
| `mix setup` | `deps.get` → `ecto.create` → `ecto.migrate` → seeds |
| `mix ecto.reset` | Drop → create → migrate → seeds |
| `mix test` | Create DB (quiet) → migrate (quiet) → run tests |

## Notable Dependencies

- **Phoenix 1.8** + **Bandit** (HTTP server)
- **Guardian** + **bcrypt_elixir** — JWT auth
- **Noizu Labs Entities** — entity framework
- **GenAI** — LLM integration
- **Syn** — process registry / routing
- **Redix** — Redis client
- **PostGIS / pgvector / geo** — spatial + vector DB extensions
