# Project Layout Summary — codefre.sh

```
codefre.sh/
├── app/                            # Runnable full-stack scaffold
│   ├── frontend/                   #   Next.js 15 app
│   ├── backend/                    #   Phoenix 1.8 API (Codefresh / CodefreshWeb)
│   ├── nginx/                      #   Reverse proxy
│   ├── scripts/gen-env.sh          #   Env generator
│   ├── docs/                       #   Scaffold docs
│   ├── docker-compose.yaml         #   Service orchestration
│   ├── docker-compose.dev.yaml     #   Dev overrides
│   ├── Makefile                    #   Build + lifecycle
│   ├── .env.example                #   Env template
│   └── .tool-versions              #   asdf pins
├── design/                         # Design directions + logo
│   ├── direction-{a..d}-*.*        #   Four design directions (D = primary)
│   ├── logo.svg
│   └── README.md
├── docs/                           # Project-root docs
│   ├── PROJ-ARCH.md
│   ├── PROJ-LAYOUT.md
│   ├── IMPLEMENTATION-PLAN.md
│   ├── next-steps.md
│   ├── cypress-attributes.md
│   ├── arch/                       #   audit-report, data-model, freeball-protocol, rubric-dsl, schema-requirements, yaml-script-schema
│   ├── personas/                   #   7 persona specs
│   ├── user-stories/               #   150 stories (all waves complete) + README + index
│   └── ux/                         #   ~75 PlantUML wireframes
├── cli/                            # Elixir escript CLI
├── sdks/                           # Client SDKs (python, typescript, elixir)
├── web/                            # Landing / waitlist site (standalone Next.js)
├── helm/codefresh/                 # Kubernetes Helm chart
├── scripts/                        # Dev tooling (user-stories index regen)
├── .claude/                        # Claude agents + slash commands
├── .github/workflows/              # CI (backend, frontend, story-status)
├── .tool-versions                  # nodejs 22.22.0
├── CLAUDE.md                       # Project instructions
└── README.md                       # Elevator pitch + Freeball Protocol
```
