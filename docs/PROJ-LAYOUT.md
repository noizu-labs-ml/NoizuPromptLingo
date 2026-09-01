# Project Layout — NoizuPromptLingo (NPL)

Multi-tenant agent/human collaboration platform ("tobor"): **Elixir Phoenix API** (`backend/`, OTP app `:noizu_prompt_lingua`) + **Python MCP fleet** (`src/npl_mcp`), **Next.js console** (`frontend/`), nginx proxy, satellite TypeScript packages. Product overview: [README.md](../README.md). Architecture detail: [PROJ-ARCH.md](PROJ-ARCH.md).

```
NoizuPromptLingo/
├── backend/                        # Elixir Phoenix API (Ecto, MCP endpoint, Guardian auth, TRP client) → [layout/backend.md](layout/backend.md)
├── src/                            # Python MCP packages → [layout/src.md](layout/src.md)
│   ├── npl_mcp/                    #   Main NPL MCP package (FastAPI + FastMCP: agents, artifacts, browser tools, chat,
│   │                               #     instructions, markdown, meta_tools, npl parser, orchestration, pipes, pm_tools,
│   │                               #     sessions, skills, storage (asyncpg), tasks, tool_sessions, web, launcher.py)
│   ├── npl_persona/                #   Persona simulation CLI (analysis, journal, knowledge, teams, templates)
│   └── mcp.py                      #   Minimal FastMCP hello-world server
├── frontend/                       # Next.js web UI (React/TypeScript/Tailwind)
│   ├── src/                        #   App router code (app/, components/, config/, context/, hooks/, i18n/, lib/, types/)
│   ├── packages/npl-queue-board    #   Shared internal component package
│   ├── cypress/ + e2e/             #   Cypress + Playwright E2E suites
│   ├── legacy-app/                 #   Archived prior frontend
│   ├── docs/                       #   Frontend-scoped docs (PROJ-LAYOUT.md, layout/)
│   └── package.json · next.config.ts · playwright/cypress configs
├── browser-controller/             # TypeScript browser automation service (Playwright; Dockerfile + install.sh)
├── remote-access-client/           # TypeScript remote-access tunnel client (Dockerfile + install.sh + scripts/)
├── local-mcp/                      # TypeScript local MCP helper (tools/, lib/)
├── tests/                          # Python test suites → [layout/tests.md](layout/tests.md)
├── docs/                           # Documentation → [layout/docs.md](layout/docs.md)
│   ├── arch/ · schema/ · layout/ · agents/ · claude/ · reference/ · testing/
│   ├── pending/ · prior-version/
│   ├── PROJ-LAYOUT.md              #   This file (+ .summary.md)
│   ├── PROJ-ARCH.md                #   Architecture (+ .summary.md)
│   ├── PROJ-SCHEMA.md              #   Schema doc (+ .summary.md)
│   └── PROJ-STATUS.md · features-grid.md · REMOTE-ACCESS-TUNNEL-DESIGN.md · winnower-design.md
├── project-management/             # Planning & specs → [layout/project-management.md](layout/project-management.md)
├── conventions/                    # NPL convention YAML (source of truth for NPLSpec + NPLLoad):
│                                   #   syntax, declarations, directives, prefixes, prompt-sections,
│                                   #   special-sections, pumps, npl.yaml
├── npl/                            # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                         # Agent definitions (30+ core agents, additional-agents/, skeleton/)
├── commands/                       # Claude Code slash commands
├── sub-agent-prompts/              # Reusable prompts for parallel agent spawning
├── design/                         # Theme system: 8 NPL themes (aurora, blueprint, brutalist, editorial,
│                                   #   meridian, minimal, nocturne, prism) — treatise/conformance docs + theme YAML,
│                                   #   theme-style-guide, THEMES.md, asset-prompts/
├── deploy & runtime
│   ├── charts/npl-mcp/             # Legacy Helm chart location (npl-mcp)
│   ├── helm/                       # Helm charts: npl-mcp/, start-app/ (values-sandbox.yaml)
│   ├── docker/postgres-init/       # PostgreSQL init scripts
│   ├── nginx/                      # Reverse proxy (nginx.conf + Dockerfile)
│   ├── sandbox/                    # Sandbox image support (supervisord.conf, smb.conf, entrypoint)
│   ├── docker-compose.yaml         # Base stack (PostgreSQL at localhost:5111, backend, frontend, nginx)
│   ├── docker-compose.dev.yaml · .override.yaml · .ci.yaml · .sandbox.yaml
│   ├── Dockerfile · Dockerfile.sandbox
│   └── Makefile                    # Build/task automation (init, build, run, migrate, regen, sandbox targets)
├── liquibase/                      # DB migrations (changelogs/ 001–018+, liquibase.properties.example)
├── tools/                          # Utility scripts (git_tree/git_dump, markdown, validators/, lib/)
├── plugins/llm/                    # Squash-vendored local MCP servers (doc-pointers, Google, Dropbox, run-claude)
├── scripts/                        # Operational scripts (gen-env.sh, remote-access cert minting, port-forward)
├── gh-pages                        # GitHub Pages submodule (static site, branch: gh-pages)
├── .claude/ · .agents/ · .codex/   # Agent harness configs (agents/, commands/, skills symlinks)
├── .claude-plugin/ · .grok-plugin/ # Plugin marketplace manifests (Claude / Grok)
├── .dockerignore · .gitignore · .gitmodules
├── .mise.toml · .python-version · .tool-versions   # mise + Python 3.13 toolchain
├── .env.example                    # Env template → copy to .env (root), backend/.env, frontend/.env via `make init`
├── .env                            # Generated env file (gitignored)
├── AGENTS.md · CLAUDE.md           # Agent instructions (Codex mirror / Claude Code)
├── INSTALL.md · INTEGRATION-NOTES.md · RESUME.md · README.md
├── pyproject.toml · uv.lock        # Python package + lock (console scripts: npl-mcp, npl-docs-regen)
├── package-lock.json               # Root Node lock
├── debug-command.sh · ignore.test-it.md · wip.json · LICENSE
└── staging/                        # Local worktrees (gitignored, not part of repo)
```

## Nested layout docs

| Area | Path |
|------|------|
| Backend tree | [backend/docs/PROJ-LAYOUT.md](../../backend/docs/PROJ-LAYOUT.md) |
| Backend detail | [layout/backend.md](layout/backend.md) |
| Frontend tree | [frontend/docs/PROJ-LAYOUT.md](../../frontend/docs/PROJ-LAYOUT.md) |
| Python `src/` | [layout/src.md](layout/src.md) |

## Console Scripts

| Script | Module | Description |
|--------|--------|-------------|
| `npl-mcp` | `npl_mcp.launcher:main` | Run the full NPL MCP server |
| `npl-docs-regen` | `npl_mcp.docs_regen:main` | Regenerate `npl/npl-full.md` from `conventions/` |

## Configuration Files Requiring Setup

| File | Action |
|------|--------|
| `.env` (+ `backend/.env`, `frontend/.env`) | `make init` from `.env.example` (all gitignored) |
| `liquibase/liquibase.properties` | From `liquibase.properties.example`; connection config (gitignored) |
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

## Runtime topology

External `lets-go_default` network (shared Postgres/Redis). Nginx on `$PORT` (default 8080):

- `/api/*`, `/health`, MCP/WebSocket → backend `:4000`
- `/_next/webpack-hmr` → frontend HMR
- `/*` → frontend `:3000`
