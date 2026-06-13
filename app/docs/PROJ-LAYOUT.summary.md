# Project Layout Summary — derobot.is/app

```
app/
├── frontend/                       # Next.js 15 app
│   ├── src/                        #   Pages, components, theme YAML, auth
│   ├── public/                     #   Static assets
│   ├── docs/                       #   Frontend docs
│   └── Dockerfile
├── backend/                        # Phoenix 1.8 API (Derobot)
│   ├── lib/                        #   Elixir source
│   ├── config/                     #   Mix config
│   ├── priv/repo/                  #   Migrations, seeds
│   ├── docs/                       #   Backend docs
│   └── Dockerfile
├── nginx/                          # Reverse proxy
│   ├── nginx.conf                  #   Routing rules
│   └── Dockerfile
├── scripts/
│   └── gen-env.sh                  #   Env file generator
├── docs/
│   ├── PROJ-ARCH.md
│   ├── PROJ-ARCH.summary.md
│   ├── PROJ-LAYOUT.md
│   └── PROJ-LAYOUT.summary.md
├── .env.example                    # Env template
├── .tool-versions                  # asdf versions
├── .gitignore
├── docker-compose.yaml             # Service orchestration
├── docker-compose.dev.yaml         # Dev overrides
├── docker-compose.override.yaml    # Local overrides
└── Makefile                        # Build + lifecycle
```
