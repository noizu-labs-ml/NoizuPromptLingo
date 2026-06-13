# Project Layout Summary — start-app

```
start-app/
├── frontend/                       # Next.js 15 app
│   ├── src/                        #   Pages, components, theme YAML, auth
│   ├── docs/                       #   Frontend docs
│   └── Dockerfile
├── backend/                        # Phoenix 1.8 API
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
│   ├── PROJ-LAYOUT.md
│   └── PROJ-LAYOUT.summary.md
├── .env.example                    # Env template
├── .envrc                          # direnv
├── .gitignore
├── docker-compose.yaml             # Service orchestration
└── Makefile                        # Build + lifecycle
```
