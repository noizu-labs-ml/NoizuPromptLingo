# Backend Layout

Elixir / Phoenix 1.8 API — game server with JWT auth and PostgreSQL persistence.

```
backend/
├── config/                             # Mix configuration
│   ├── config.exs                      # Base config (all envs)
│   ├── dev.exs                         # Development overrides
│   ├── prod.exs                        # Production overrides
│   ├── runtime.exs                     # Runtime config (env vars)
│   └── test.exs                        # Test overrides
├── lib/
│   ├── boe/                            # Business logic (context modules)
│   │   ├── accounts/
│   │   │   └── user.ex                 # User schema
│   │   ├── game/
│   │   │   └── character.ex            # Character schema
│   │   ├── accounts.ex                 # Accounts context
│   │   ├── application.ex              # OTP application supervisor
│   │   ├── game.ex                     # Game context
│   │   ├── guardian.ex                 # JWT token config (Guardian)
│   │   ├── mailer.ex                   # Email delivery
│   │   └── repo.ex                     # Ecto repository
│   ├── boe_web/                        # Web layer
│   │   ├── controllers/
│   │   │   ├── auth_controller.ex      # Login / signup / token refresh
│   │   │   ├── character_controller.ex # Character CRUD
│   │   │   ├── error_json.ex           # Error response formatting
│   │   │   ├── health_controller.ex    # Health check endpoint
│   │   │   └── page_html.ex            # HTML rendering helpers
│   │   ├── plugs/
│   │   │   ├── auth_error_handler.ex   # Guardian error handler
│   │   │   ├── auth_pipeline.ex        # JWT auth pipeline
│   │   │   └── cors.ex                 # CORS configuration
│   │   ├── endpoint.ex                 # Phoenix endpoint
│   │   ├── router.ex                   # Route definitions
│   │   └── telemetry.ex                # Telemetry events
│   ├── boe_web.ex                      # Web module helpers
│   └── boe.ex                          # App module helpers
├── priv/
│   └── repo/
│       ├── migrations/
│       │   ├── 20260313151844_create_users.exs
│       │   └── 20260313162715_create_characters.exs
│       └── seeds.exs                   # Database seed data
├── test/
│   ├── boe_web/controllers/
│   │   └── error_json_test.exs
│   └── support/
│       ├── conn_case.ex                # Controller test case
│       └── data_case.ex                # Data/repo test case
├── .tool-versions                      # asdf runtime versions
├── AGENTS.md                           # Gemini agent instructions
├── Dockerfile                          # Production container
├── mix.exs                             # Project definition and deps
├── mix.lock                            # Locked dependency versions
└── README.md                           # Backend-specific docs
```
