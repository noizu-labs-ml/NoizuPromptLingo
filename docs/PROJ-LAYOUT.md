# Project Layout — NoizuPromptLingo (NPL)

Multi-tenant agent/human collaboration platform (“tobor”): Phoenix API + MCP fleet, Next.js console, nginx proxy. OTP app `:noizu_prompt_lingua`. Product overview: [README.md](../README.md). Architecture detail: [PROJ-ARCH.md](PROJ-ARCH.md).

```
NoizuPromptLingo/
├── src/                            # Application source → [layout/src.md](layout/src.md)
│   ├── npl_mcp/                    #   Main NPL MCP package
│   │   ├── agents/                 #     Agent catalog and registry
│   │   ├── api/                    #     FastAPI REST router
│   │   ├── artifacts/              #     Versioned artifact CRUD + revisions
│   │   ├── browser/                #     Web tools: Ping, Screenshot, Download, Rest, Secrets, ToMarkdown, Capture, Checkpoint, Diff, Interact, Report
│   │   ├── chat/                   #     Chat rooms + messages (REST CRUD)
│   │   ├── executors/              #     Tasker agent management (stubs)
│   │   ├── instructions/           #     Instruction management + vector embeddings
│   │   ├── markdown/               #     Markdown converter, viewer, filters
│   │   ├── meta_tools/             #     Catalog + discovery: summary/search/definition/help, mcp_discoverable helper, stub_catalog, discoverable_tools, LLM client
│   │   ├── npl/                    #     NPL syntax parser and loader
│   │   ├── orchestration/          #     Multi-agent orchestration: patterns, pipeline, stages, TDD pipeline
│   │   ├── pipes/                  #     Agent input/output pipe management
│   │   ├── pm_tools/               #     PRD/story/persona management tools (file + DB)
│   │   ├── scripts/                #     Shell script wrappers (stubs)
│   │   ├── sessions/               #     Generic work-session lifecycle
│   │   ├── skills/                 #     Skill validation tools
│   │   ├── storage/                #     PostgreSQL async wrapper (asyncpg)
│   │   ├── tasks/                  #     Task CRUD with status tracking
│   │   ├── tool_sessions/          #     Tool session and project management
│   │   ├── web/                    #     FastAPI routes + static assets
│   │   ├── convention_formatter.py #     NPL convention YAML formatter
│   │   ├── docs_regen.py           #     Regenerate npl-full.md from conventions/
│   │   ├── structured_logging.py   #     Structured logging utilities
│   │   └── launcher.py             #     CLI entry point with server management
│   ├── npl_persona/                #   Persona simulation CLI (analysis, journal, knowledge, teams, templates)
│   └── mcp.py                      #   Minimal FastMCP hello-world server
├── frontend/                       # Next.js web UI (React/TypeScript/Tailwind)
│   ├── app/                        #   App router (layout, page, globals)
│   ├── components/                 #   React components (primitives, composites, forms, modals, shell)
│   ├── cypress/                    #   E2E test suite (e2e/, fixtures/, support/)
│   ├── lib/                        #   API client + utilities (api/, utils/)
│   ├── cypress.config.ts           #   Cypress E2E configuration
│   ├── package.json                #   Node dependencies
│   └── tsconfig.json               #   TypeScript config
├── tests/                          # Test suites → [layout/tests.md](layout/tests.md)
│   ├── assets/                     #   Test fixture files (markdown, HTML, PDF)
│   ├── conftest.py                 #   Shared fixtures (_mcp_app session scope, cache clearing)
│   └── 42 test files               #   Unit/integration/e2e (catalog, browser, markdown, PM, sessions, orchestration, etc.)
├── docs/                           # Documentation → [layout/docs.md](layout/docs.md)
│   ├── arch/                       #   Architecture docs (orchestration, pipes, assumptions, rest-api, etc.)
│   ├── agents/                     #   Agent-specific documentation (control-agent, sub-agent, tools)
│   ├── claude/                     #   Claude Code tooling docs
│   ├── layout/                     #   Layout detail files (src, tests, docs, project-management, user-stories)
│   ├── reference/                  #   Reference docs (FastMCP, MCP, skills, SKILL-GUIDELINE, SKILL-QUICKSTART)
│   ├── schema/                     #   Schema detail files (instructions, PM, NPL)
│   ├── testing/                    #   Testing guides (cypress-attributes)
│   ├── pending/                    #   Docs pending integration
│   ├── prior-version/              #   Archived docs from prior version
│   ├── features-grid.md            #   Feature grid overview
│   ├── PROJ-ARCH.md                #   High-level architecture
│   ├── PROJ-ARCH.summary.md        #   Architecture summary (compact)
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Layout summary (compact)
│   ├── PROJ-SCHEMA.md              #   Database schema documentation
│   ├── PROJ-SCHEMA.summary.md      #   Schema summary (compact)
│   ├── PROJ-STATUS.md              #   Current project status and progress
│   └── winnower-design.md          #   Winnower agent design document
├── project-management/             # Planning & specs → [layout/project-management.md](layout/project-management.md)
│   ├── personas/                   #   Persona definitions with index.yaml
│   ├── user-stories/               #   151 user stories with index.yaml
│   ├── PRDs/                       #   Product requirement documents (PRD-001–018 + archive + index.yaml)
│   ├── TODO/                       #   Backlog items
│   ├── personas.md                 #   Personas overview doc
│   ├── personas.summary.md         #   Personas compact summary
│   ├── prd.md                      #   PRD overview doc
│   ├── prd.summary.md              #   PRD compact summary
│   ├── user-stories.md             #   User stories overview doc
│   └── user-stories.summary.md     #   User stories compact summary
├── conventions/                    # NPL convention YAML definitions (source of truth for NPLSpec + NPLLoad)
│   ├── declarations.yaml           #   Declaration syntax rules
│   ├── directives.yaml             #   Directive syntax rules
│   ├── npl.yaml                    #   Top-level NPL conventions
│   ├── prefixes.yaml               #   Prefix syntax rules
│   ├── prompt-sections.yaml        #   Prompt section definitions
│   ├── pumps.yaml                  #   Pump (chain-of-thought, etc.) definitions
│   ├── special-sections.yaml       #   Special section rules
│   └── syntax.yaml                 #   Core syntax definitions
├── npl/                            # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                         # Agent definitions (30+ primary agents)
│   ├── additional-agents/          #   24+ additional specialist agents (not yet in main catalog)
│   ├── skeleton/                   #   Agent template scaffolds (npl-template.md files)
│   └── *.md                        #   Core agents: TDD, taskers, persona, coordinator, domain, etc.
├── commands/                       # Claude Code slash commands (15 commands)
├── charts/                         # Helm charts
│   └── npl-mcp/                    #   Helm chart for deploying NPL MCP server (Chart.yaml, values.yaml, templates/)
├── sub-agent-prompts/              # Reusable prompts for parallel agent spawning
├── scripts/                        # Operational scripts (port forwarding, etc.)
├── liquibase/                      # Database migrations (Liquibase YAML changelogs)
│   ├── changelogs/                 #   Migration changesets (001–018)
│   ├── liquibase.properties        #   Connection config (gitignored)
│   └── liquibase.properties.example#   Template for local setup
├── docker/                         # Docker configuration
│   └── postgres-init/              #   PostgreSQL init scripts
├── tools/                          # Utility scripts (git_tree, git_dump, markdown, validators, arize)
│   ├── lib/                        #   Shared tool library (git_helpers)
│   └── validators/                 #   Skill/eval/fine-tune/structure validators
├── gh-pages                        # GitHub Pages submodule (static site, branch: gh-pages)
├── .claude/                        # Claude Code configuration
│   ├── agents/                     #   Agent definitions (symlinks + local)
│   ├── commands/                   #   Slash command definitions
│   ├── skills                      #   Symlink → lets-go/skills
│   └── settings.local.json         #   Local settings (gitignored)
├── .agents/                        # Alternate agent discovery path
│   └── skills                      #   Symlink → lets-go/skills
├── .codex/                         # Codex agent configuration (mirrors .claude/ for Codex)
│   └── agents/                     #   Codex agent definitions
├── .prd/                           # PRD workspace
├── .tmp/                           # Temporary/scratch files (gitignored)
├── .dockerignore                   # Docker build exclusions
├── .envrc                          # direnv — loads environment
├── .gitignore                      # Git ignore rules
├── .gitmodules                     # Git submodule definitions (gh-pages)
├── .mise.toml                      # mise task runner configuration
├── .python-version                 # Python version (3.13)
├── .tool-versions                  # Tool version management (mise)
├── AGENTS.md                       # Codex instructions (mirrors CLAUDE.md for Codex)
├── CLAUDE.md                       # Claude Code instructions
├── debug-command.sh                # Debug/diagnostic shell script
├── docker-compose.yaml             # Local dev services (PostgreSQL at localhost:5111)
├── Dockerfile                      # Container build definition
├── INSTALL.md                      # Installation guide
├── LICENSE                         # Project license
├── Makefile                        # Build and task automation targets
├── package-lock.json               # Node package lock (frontend deps)
├── pyproject.toml                  # Project metadata and dependencies
├── README.md                       # Start here
├── RESUME.md                       # Project resumption / continuation notes
└── uv.lock                         # Dependency lock file
```

## Nested layout docs

| Area | Path |
|------|------|
| Frontend tree | [frontend/docs/PROJ-LAYOUT.md](../frontend/docs/PROJ-LAYOUT.md) |
| Frontend `src/` | [frontend/docs/layout/src.md](../frontend/docs/layout/src.md) |
| Backend tree | [backend/docs/PROJ-LAYOUT.md](../backend/docs/PROJ-LAYOUT.md) |
| Backend `lib/` | [backend/docs/layout/lib.md](../backend/docs/layout/lib.md) |

## Console Scripts

| Script | Module | Description |
|--------|--------|-------------|
| `npl-mcp` | `npl_mcp.launcher:main` | Run the full NPL MCP server |
| `npl-docs-regen` | `npl_mcp.docs_regen:main` | Regenerate `npl/npl-full.md` from `conventions/` |

## Configuration Files Requiring Setup

| File | Action |
|------|--------|
| `.env` (+ `backend/.env`, `frontend/.env`) | `make init` from `.env.example` |
| `.envrc` | `direnv allow` after secrets hydrate |
| `frontend/.npmrc` | From `.npmrc.template` if using GitHub Packages (`@noizu/styleguide`) |

## Common Make targets

| Command | Purpose |
|---------|---------|
| `make init` | Generate env files with secrets |
| `make build` / `make run` | Build images / start stack (nginx `:8080`) |
| `make run-dev` / `make stop-dev` | Hot-reload compose |
| `make migrate` | Liquibase changelogs |
| `make regen` | Theme YAML → design-system CSS |
| `make downloads-package` | Bundle local-mcp / browser-controller / remote-access-client into `backend/priv/static/downloads` |
| `make sandbox` / `make run-sandbox` | Combined sandbox image + Samba |

| Category | Agents | Purpose |
|----------|--------|---------|
| TDD Pipeline | `npl-idea-to-spec`, `npl-prd-editor`, `npl-tdd-tester`, `npl-tdd-coder`, `npl-tdd-debugger` | Feature specification through implementation |
| Taskers | `npl-tasker`, `npl-tasker-haiku/fast/sonnet/opus/ultra` | Task execution at various cost/capability levels |
| Authoring | `npl-author`, `npl-marketing-writer`, `npl-technical-writer` | Content generation and NPL prompt authoring |
| Analysis | `npl-winnower`, `npl-gopher-scout`, `npl-thinker`, `npl-grader` | Code exploration, reasoning, validation |
| Persona | `npl-persona`, `npl-persona-manager` | Character simulation and persona management |
| Coordination | `npl-project-coordinator`, `npl-prd-manager` | Task orchestration and PRD lifecycle |
| Domain | `npl-sql-architect`, `npl-build-master`, `npl-cpp-modernizer`, `npl-perf-profiler`, `npl-threat-modeler` | Specialized domain expertise |
| Other | `npl-fim`, `npl-templater`, `nimps`, `nb` | Visualization, template management, notebook |

Additional specialists (not yet in main registry) live in `agents/additional-agents/`.

External `lets-go_default` (shared Postgres/Redis). Nginx on `$PORT` (default 8080):

- `/api/*`, `/health`, MCP/WebSocket → backend `:4000`
- `/_next/webpack-hmr` → frontend HMR
- `/*` → frontend `:3000`
