# Project Layout Summary — start-app

```
start-app/
├── frontend/                       # Next.js 15 app
│   ├── src/                        #   Pages, components, theme YAML, auth
│   ├── docs/                       #   Frontend docs
│   ├── docker-entrypoint.sh        #   Runtime config injection
│   ├── Dockerfile                  #   Production build
│   └── Dockerfile.dev              #   Dev build (hot reload)
├── backend/                        # Phoenix 1.8 API
│   ├── lib/                        #   Elixir source
│   ├── config/                     #   Mix config
│   ├── priv/repo/                  #   Ecto migrations, seeds
│   ├── db/                         #   Liquibase schema management
│   │   ├── changelog/              #     Versioned YAML changesets
│   │   ├── liquibase.properties    #     Connection config
│   │   └── Dockerfile              #     Migration runner image
│   ├── docs/                       #   Backend docs
│   ├── Dockerfile                  #   Production build
│   └── Dockerfile.dev              #   Dev build (hot reload)
├── nginx/                          # Reverse proxy
│   ├── nginx.conf                  #   Routing rules
│   └── Dockerfile
├── helm/                           # Kubernetes deployment
│   └── start-app/                  #   Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/              #   K8s manifests
├── scripts/
│   └── gen-env.sh                  #   Env file generator
├── docs/
│   ├── PROJ-LAYOUT.md
│   ├── PROJ-LAYOUT.summary.md
│   ├── PROJ-ARCH.md
│   └── PROJ-ARCH.summary.md
├── .env.example                    # Env template
├── .envrc                          # direnv
├── .tool-versions                  # asdf/mise runtime versions
├── .gitignore
├── docker-compose.yaml             # Production services
├── docker-compose.dev.yaml         # Dev overrides (hot reload)
└── Makefile                        # Build + lifecycle
```
