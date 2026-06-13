# Project Layout — codefre.sh

**NOIZUAI-24: CodeFre.sh** — Scripted agent evaluation with fuzzy state machines and a Freeball Protocol for handling conversational deviation.

Portfolio project split across multiple layers: a **landing site** (`web/`), **design artifacts** (`design/`), a **runnable full-stack scaffold** under `app/` (Next.js frontend + Phoenix backend + nginx proxy), a **CLI** (`cli/`), **client SDKs** (`sdks/`), and **Helm charts** for Kubernetes deployment (`helm/`).

```
codefre.sh/
├── app/                            # Runnable full-stack scaffold → [../app/docs/PROJ-LAYOUT.md](../app/docs/PROJ-LAYOUT.md)
│   ├── frontend/                   #   Next.js 15 (App Router, auth, theme YAML, waitlist)
│   ├── backend/                    #   Phoenix 1.8 API (Codefresh app + CodefreshWeb, Guardian JWT, Ecto)
│   ├── nginx/                      #   Reverse proxy (/api → backend, /* → frontend)
│   ├── scripts/gen-env.sh          #   Generates .env files with secrets for all services
│   ├── docs/                       #   Scaffold-level architecture + layout docs
│   ├── docker-compose.yaml         #   Service orchestration (prod)
│   ├── docker-compose.dev.yaml     #   Dev overrides (HMR, volume mounts)
│   ├── docker-compose.override.yaml#   Local-only overrides (gitignored pattern)
│   ├── Makefile                    #   Build + lifecycle (init, build, run, push)
│   ├── .env.example                #   Environment template — run `make init`
│   └── .tool-versions              #   asdf tool pins (Elixir/Erlang)
├── design/                         # Design exploration and brand assets
│   ├── direction-a-minimal-tech.{md,html}       #   Direction A: minimal / tech
│   ├── direction-b-minimal-editorial.{md,html}  #   Direction B: minimal / editorial
│   ├── direction-c-neo-brutalist.{md,html}      #   Direction C: neo-brutalist
│   ├── direction-d-forge.{md,html}              #   Direction D: forge (primary candidate)
│   ├── direction-d-forge-creative.html          #   Direction D: creative variant
│   ├── logo.svg                    #   Primary logo mark
│   └── README.md                   #   Design direction index
├── docs/                           # Project-root documentation
│   ├── PROJ-ARCH.md                #   System architecture
│   ├── PROJ-ARCH.summary.md        #   Architecture quick reference
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Tree-only quick reference
│   ├── IMPLEMENTATION-PLAN.md      #   Phased implementation roadmap
│   ├── next-steps.md               #   Current priorities and next actions
│   ├── cypress-attributes.md       #   Cypress test attribute conventions
│   ├── arch/                       #   Architecture deep-dives
│   │   ├── audit-report.md         #     Architecture audit findings
│   │   ├── data-model.md           #     Canonical schema reference (ERD + per-column detail)
│   │   ├── freeball-protocol.md    #     Freeball state machine + promotion lifecycle
│   │   ├── rubric-dsl.md           #     Rubric DSL grammar and evaluation semantics
│   │   ├── schema-requirements.md  #     Analyst output: schema deltas surfaced by 150 stories
│   │   └── yaml-script-schema.md   #     YAML script import/export schema specification
│   ├── personas/                   #   7 persona specs (priya, marcus, yuki, alex, sofia, derek, nia)
│   ├── user-stories/               #   150 user stories — all three waves complete (US-001..US-150)
│   │   ├── README.md               #     Conventions, 15 categories, frontmatter schema (Jira/Linear/GitHub mapped)
│   │   ├── index.md                #     Regenerated catalog — status transitions per PR
│   │   └── US-NNN-{slug}.md        #     One file per story (flat)
│   └── ux/                         #   PlantUML wireframes (~75 screens)
│       ├── README.md               #     Wireframe index and conventions
│       └── *.puml                  #     Screen wireframes (agent, run, script, dataset, etc.)
├── scripts/                        # Dev tooling
│   ├── regen-user-stories-index.py #   Rebuild docs/user-stories/index.md from frontmatter
│   └── regen-user-stories-index.sh #   Shell wrapper around the .py
├── cli/                            # Standalone Elixir escript — `codefresh` binary
│   ├── mix.exs                     #   Escript project (jason/req/yaml_elixir)
│   ├── lib/codefresh_cli.ex        #   Entry + command dispatch
│   ├── lib/codefresh_cli/          #   config, client, args, junit, commands/
│   └── test/                       #   20 unit tests (args/config/junit/dispatch)
├── sdks/                           # Client SDK scaffolds
│   ├── python/                     #   sync + async Client, pydantic models, verify_webhook_signature
│   ├── typescript/                 #   Web-Crypto HMAC, edge-compatible types
│   └── elixir/                     #   Client + Runs + Scripts + Webhooks modules
├── web/                            # Landing / waitlist site (standalone Next.js)
│   ├── src/app/                    #   App Router pages (landing page, waitlist form)
│   ├── public/                     #   Static assets (SVG icons)
│   ├── Dockerfile                  #   Multi-stage build (Next.js + nginx)
│   ├── nginx.conf                  #   Production static serving config
│   ├── build.sh                    #   Docker build script
│   ├── package.json                #   Dependencies (next, react, tailwindcss)
│   └── tsconfig.json               #   TypeScript config
├── helm/                           # Kubernetes Helm chart
│   └── codefresh/                  #   Main deployment chart
│       ├── templates/              #     K8s manifests (deployment, ingress, service, migrate-job, tls)
│       ├── Chart.yaml              #     Chart metadata
│       └── values.yaml             #     Default values
├── .claude/                        # Claude Code configuration
│   ├── agents/                     #   Project agent definitions (tasker, tdd-*, prd-editor)
│   ├── commands/                   #   Slash-command definitions (npl-*, manners)
│   └── settings.local.json         #   Local Claude settings (gitignored)
├── .tool-versions                  # asdf: nodejs 22.22.0
├── .git                            # Submodule pointer file (this dir is a git submodule)
├── .gitignore                      # Git ignore rules
├── CLAUDE.md                       # Project instructions for Claude Code
└── README.md                       # Elevator pitch, problem statement, Freeball Protocol design
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `app/.env` | Run `make -C app init` to generate from `.env.example` with real secrets |
| `app/frontend/.npmrc` | Copy from `.npmrc.template`, add GitHub Packages token |
| `app/backend/.tool-versions` | Run `asdf install` in `app/backend/` to match Elixir/Erlang versions |
| `.tool-versions` | Run `asdf install` at project root for nodejs 22.22.0 |

## Navigating Deeper

- **System architecture**: [`PROJ-ARCH.md`](PROJ-ARCH.md)
- **Data model** (schema, versioning, OTel ingestion): [`arch/data-model.md`](arch/data-model.md)
- **Freeball Protocol** (state machine + promotion lifecycle): [`arch/freeball-protocol.md`](arch/freeball-protocol.md)
- **User personas** (seven, with schema-requirement mappings): [`personas/`](personas/)
- **User stories** (150, all waves complete): [`user-stories/README.md`](user-stories/README.md) + [`user-stories/index.md`](user-stories/index.md)
- **UX wireframes** (~75 PlantUML screens): [`ux/`](ux/) + [`ux/README.md`](ux/README.md)
- **Implementation plan**: [`IMPLEMENTATION-PLAN.md`](IMPLEMENTATION-PLAN.md)
- **Scaffold layout** (frontend/backend/nginx details, Make targets, network topology): [`app/docs/PROJ-LAYOUT.md`](../app/docs/PROJ-LAYOUT.md)
- **Frontend layout** (App Router pages, theme system, components): [`app/frontend/docs/PROJ-LAYOUT.md`](../app/frontend/docs/PROJ-LAYOUT.md)
- **Backend layout** (Codefresh app, CodefreshWeb, migrations): [`app/backend/docs/PROJ-LAYOUT.md`](../app/backend/docs/PROJ-LAYOUT.md)

## Repository Context

This project is a **git submodule** under the incubator monorepo at `projects/apps/repos/incubator/projects/codefre.sh/`. The enclosing repo provides shared infrastructure (Postgres/Redis via `docker-compose.yaml` in incubator root), scaffold tooling (`init-proj-scaffold`), and the `@the-robot-lives/styleguide` design system package consumed by `app/frontend/`.
