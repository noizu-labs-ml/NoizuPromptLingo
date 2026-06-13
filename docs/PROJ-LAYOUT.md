# Project Layout

Blade of Eternity — accessibility-first text RPG built on Next.js + Elixir/Phoenix.

```
bladeofeternity.com/
├── web/                                # Next.js 15 frontend → [layout/web.md](layout/web.md)
│   ├── src/app/                        #   App Router pages + components
│   ├── e2e/                            #   BDD feature specs (Gherkin + Cypress)
│   ├── cypress/                        #   Cypress test support
│   └── public/                         #   Static assets and images
├── backend/                            # Elixir/Phoenix API → [layout/backend.md](layout/backend.md)
│   ├── lib/boe/                        #   Business logic contexts
│   ├── lib/boe_web/                    #   Web layer (controllers, plugs, router)
│   ├── priv/repo/migrations/           #   Ecto migrations
│   └── config/                         #   Mix configuration
├── project/                            # Product management → [layout/project.md](layout/project.md)
│   ├── personas/                       #   10 user personas (accessibility-focused)
│   └── user-stories/                   #   100 user stories (001–100)
├── design/                             # Design artifacts
│   ├── style-guide.html                #   Visual style guide
│   └── ux-architecture.md              #   Screen reader interaction patterns
├── docs/                               # Documentation
│   ├── PROJ-LAYOUT.md                  #   This file
│   ├── PROJ-LAYOUT.summary.md          #   Quick-reference tree
│   ├── cypress-attributes.md           #   Cypress test attribute schema
│   ├── README.md                       #   Docs index (sidecar file reference)
│   └── layout/                         #   Detailed directory breakdowns
│       ├── web.md
│       ├── backend.md
│       └── project.md
├── .gemini/                            # Gemini Code Assist config
│   ├── config.yaml                     #   Review settings
│   └── styleguide.md                   #   Code style rules
├── .gitignore                          # Git ignore rules
├── .tool-versions                      # asdf runtime versions (Elixir, Erlang, Node)
├── docker-compose.yaml                 # Local dev services (PostgreSQL, Redis)
└── README.md                           # Project overview, vision, architecture
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.tool-versions` | Install runtimes via `asdf install` |
| `docker-compose.yaml` | Run `docker compose up -d` for PostgreSQL/Redis |
| `backend/config/dev.exs` | Verify database connection settings |
| `web/package.json` | Run `npm install` in `web/` |
| `backend/mix.exs` | Run `mix deps.get` in `backend/` |

## Conventions

- **Cypress sidecars**: Every page with `cyAttrs()` calls has a co-located `.cy.yaml` file documenting test selectors. See [cypress-attributes.md](cypress-attributes.md).
- **User stories**: Numbered 001–100, organized by domain (accessibility → combat → world → economy → onboarding). See [layout/project.md](layout/project.md).
- **Contexts**: Backend follows Phoenix context pattern — `Boe.Accounts`, `Boe.Game` encapsulate domain logic.
