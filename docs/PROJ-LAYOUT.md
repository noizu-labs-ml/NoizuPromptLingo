# Project Layout

```
NoizuPromptLingo/
├── src/                            # Application source → [layout/src.md](layout/src.md)
│   ├── npl_mcp/                    #   Main NPL MCP package
│   │   ├── markdown/               #     Markdown converter, viewer, filters
│   │   ├── meta_tools/             #     MCP tool catalog, search, LLM client
│   │   ├── npl/                    #     NPL syntax parser and loader
│   │   ├── pm_tools/               #     PRD/story/persona management tools
│   │   ├── web/                    #     FastAPI routes + static assets
│   │   ├── storage/                #     PostgreSQL async wrapper (asyncpg)
│   │   ├── artifacts/              #     Versioned artifact management (stubs)
│   │   ├── browser/                #     Browser automation (stubs)
│   │   ├── chat/                   #     Event-sourced chat rooms (stubs)
│   │   ├── executors/              #     Tasker agent management (stubs)
│   │   ├── scripts/                #     Shell script wrappers (stubs)
│   │   ├── sessions/               #     Session lifecycle (stubs)
│   │   ├── tasks/                  #     Task queues (stubs)
│   │   └── launcher.py             #     CLI entry point with server management
│   └── mcp.py                      #   Minimal FastMCP hello-world server
├── frontend/                       # Next.js web UI (React/TypeScript/Tailwind)
│   ├── app/                        #   App router (layout, page, globals)
│   ├── components/                 #   React components
│   ├── package.json                #   Node dependencies
│   └── tsconfig.json               #   TypeScript config
├── tests/                          # Test suites → [layout/tests.md](layout/tests.md)
├── docs/                           # Documentation → [layout/docs.md](layout/docs.md)
│   ├── arch/                       #   Architecture docs
│   ├── reference/                  #   Reference docs (MCP, FastMCP, skills)
│   ├── pending/                    #   Docs pending integration
│   ├── prior-version/              #   Archived docs from prior version
│   ├── PROJ-ARCH.md                #   High-level architecture
│   └── PROJ-LAYOUT.md              #   This file
├── project-management/             # Planning & specs → [layout/project-management.md](layout/project-management.md)
│   ├── personas/                   #   Persona definitions with index.yaml
│   ├── user-stories/               #   130+ user stories with index.yaml
│   ├── PRDs/                       #   Product requirement documents (PRD-001–017)
│   └── TODO/                       #   Backlog items
├── npl/                            # NPL language specifications (YAML + Markdown)
├── skills/                         # Skill definitions (conversion, market, UX, monetization)
├── agents/                         # TDD agent definitions (npl-*.md)
├── commands/                       # Claude Code slash commands
├── sub-agent-prompts/              # Reusable prompts for parallel agent spawning
├── liquibase/                      # Database migrations (Liquibase YAML changelogs)
│   ├── changelogs/                 #   Migration changesets
│   ├── liquibase.properties        #   Connection config
│   └── liquibase.properties.example#   Template for local setup
├── docker/                         # Docker configuration
│   └── postgres-init/              #   PostgreSQL init scripts
├── tools/                          # Utility scripts (git_tree, git_dump, markdown, validators)
├── worktrees/                      # Git worktrees (extended workspace)
│   ├── main/                       #   Main branch with full NPL framework
│   └── npl-update/                 #   Update worktree
├── .claude/                        # Claude Code configuration
│   ├── commands -> ../commands     #   Symlink to commands/
│   ├── agents -> ../agents         #   Symlink to agents/
│   └── settings.local.json         #   Local settings (gitignored)
├── .tmp/                           # Temporary/scratch files (gitignored)
├── .envrc                          # direnv — loads environment
├── .mise.toml                      # mise task runner configuration
├── .python-version                 # Python version (3.13)
├── .tool-versions                  # Tool version management
├── docker-compose.yaml             # Local dev services (PostgreSQL)
├── pyproject.toml                  # Project metadata and dependencies
├── uv.lock                         # Dependency lock file
├── CLAUDE.md                       # Claude Code instructions
├── LICENSE                         # Project license
└── README.md                       # Start here
```

## Key Entry Points

| File | Description |
|------|-------------|
| `src/npl_mcp/launcher.py` | CLI entry point — server management, PID files, Uvicorn |
| `src/mcp.py` | Minimal FastMCP server with single `hello` tool (for experiments) |
| `frontend/app/page.tsx` | Next.js web UI entry page |

## Console Scripts

| Script | Module | Description |
|--------|--------|-------------|
| `npl-mcp` | `npl_mcp.launcher:main` | Run the full NPL MCP server |

## Configuration Files Requiring Setup

| File | Action |
|------|--------|
| `.envrc` | Run `direnv allow` to load environment |
| `liquibase/liquibase.properties` | Copy from `.example`, configure DB connection |
| `docker-compose.yaml` | `docker compose up -d` for PostgreSQL at localhost:5111 |

## TDD Agent Workflow

Agents defined in `agents/` (symlinked via `.claude/agents`):

| Agent | Purpose |
|-------|---------|
| `npl-idea-to-spec` | Transform ideas to personas + user stories |
| `npl-prd-editor` | Generate PRD documents from user stories |
| `npl-tdd-tester` | Create comprehensive test suites |
| `npl-tdd-coder` | Implement features using TDD cycle |
| `npl-tdd-debugger` | Diagnose and fix test failures |
| `npl-tasker-*` | Task execution agents (haiku/fast/sonnet/opus/ultra) |

## Generated Directories (gitignored)

| Directory | Purpose |
|-----------|---------|
| `.venv/` | Virtual environment created by `uv sync` |
| `.tmp/` | Temporary files for agent work and scratch |
| `htmlcov/` | HTML coverage reports from pytest-cov |
| `.pytest_cache/` | pytest cache |
| `.ruff_cache/` | Ruff linting cache |
| `.coverage` | pytest coverage data file |
| `frontend/.next/` | Next.js build output |
