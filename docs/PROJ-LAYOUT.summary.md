# Project Layout Summary — NoizuPromptLingo

Companion tree for [PROJ-LAYOUT.md](PROJ-LAYOUT.md).

```
NoizuPromptLingo/
├── backend/                # Elixir Phoenix API (:noizu_prompt_lingua — domains/, entities/, mcp/, trp/, web layer, priv/repo/migrations) → layout/backend.md
├── src/npl_mcp/            # Main Python MCP package (agents, api, artifacts, browser, chat, instructions, markdown, meta_tools, npl, orchestration, pipes, pm_tools, sessions, skills, storage, tasks, tool_sessions, web)
├── src/npl_persona/        # Persona simulation CLI (analysis, journal, knowledge, teams, templates)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (src/app + components, packages/npl-queue-board, cypress/ + e2e/, legacy-app/)
├── browser-controller/     # TypeScript browser automation service
├── remote-access-client/   # TypeScript remote-access tunnel client
├── local-mcp/              # TypeScript local MCP helper
├── tests/                  # Python test suites (conftest.py + 40+ test files)
├── docs/                   # PROJ-ARCH/LAYOUT/SCHEMA + arch/, schema/, layout/, agents/, claude/, reference/, testing/, pending/, prior-version/
├── project-management/     # Personas, user stories, PRDs, roadmap, TODOs + index.yaml files
├── conventions/            # NPL convention YAML definitions (source of truth for NPLSpec/NPLLoad)
├── npl/                    # Generated NPL artifacts (npl-full.md)
├── agents/                 # Agent definitions (core + additional-agents/ + skeleton/)
├── commands/               # Claude Code slash commands
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── design/                 # Theme system (8 NPL themes, theme-style-guide, THEMES.md, asset-prompts/)
├── charts/npl-mcp/         # Helm chart (legacy location)
├── helm/                   # Helm charts: npl-mcp/, start-app/
├── docker/                 # Docker config (PostgreSQL init)
├── nginx/                  # Reverse proxy config + image
├── sandbox/                # Sandbox image support (supervisord, Samba)
├── liquibase/              # Database migrations (Liquibase YAML changelogs)
├── tools/                  # Utility scripts (git, markdown, validators)
├── plugins/llm/            # Squash-vendored local LLM MCP plugins (doc-pointers, Google, Dropbox, run-claude)
├── scripts/                # Operational scripts (gen-env, remote-access certs, port-forward)
├── gh-pages                # GitHub Pages submodule
├── .claude/ · .agents/ · .codex/            # Agent harness configs
├── .claude-plugin/ · .grok-plugin/          # Plugin marketplace manifests
├── .mise.toml · .python-version · .tool-versions   # mise + Python 3.13 toolchain
├── .env.example            # Env template (→ .env, backend/.env, frontend/.env via `make init`)
├── docker-compose*.yaml    # Base/dev/ci/sandbox/override compose stacks
├── Dockerfile · Dockerfile.sandbox          # Container builds
├── Makefile                # Build/task automation (init, build, run, migrate, regen, sandbox)
├── pyproject.toml · uv.lock                  # Python package + lock
├── package-lock.json       # Root Node lock
├── CLAUDE.md · AGENTS.md   # Claude Code / Codex instructions
├── INSTALL.md · INTEGRATION-NOTES.md · RESUME.md · README.md
└── staging/                # Local worktrees (gitignored)
```
