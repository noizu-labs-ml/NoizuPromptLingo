# Project Layout

```
NoizuPromptLingo/
├── src/                            # Application source → [layout/src.md](layout/src.md)
│   ├── npl_mcp/                    #   Main NPL MCP package
│   │   ├── markdown/               #     Markdown converter, viewer, filters
│   │   ├── meta_tools/             #     Tool catalog, search, definition, help, LLM client
│   │   ├── npl/                    #     NPL syntax parser and loader
│   │   ├── pm_tools/               #     PRD/story/persona management tools (file + DB)
│   │   ├── instructions/           #     Instruction management + vector embeddings
│   │   ├── tool_sessions/          #     Tool session and project management
│   │   ├── web/                    #     FastAPI routes + static assets
│   │   ├── storage/                #     PostgreSQL async wrapper (asyncpg)
│   │   ├── browser/                #     Ping, Screenshot, Download, Rest, Secrets, ToMarkdown
│   │   ├── artifacts/              #     Versioned artifact management (stubs)
│   │   ├── chat/                   #     Event-sourced chat rooms (stubs)
│   │   ├── executors/              #     Tasker agent management (stubs)
│   │   ├── scripts/                #     Shell script wrappers (stubs)
│   │   ├── sessions/               #     Session lifecycle (stubs)
│   │   ├── tasks/                  #     Task queues (stubs)
│   │   ├── convention_formatter.py #     NPL convention YAML formatter
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
│   ├── agents/                     #   Agent-specific documentation
│   ├── claude/                     #   Claude Code tooling docs
│   ├── layout/                     #   Layout detail files (src, tests, docs, etc.)
│   ├── reference/                  #   Reference docs (MCP, FastMCP, skills)
│   ├── schema/                     #   Schema detail files (instructions, PM, NPL)
│   ├── pending/                    #   Docs pending integration
│   ├── prior-version/              #   Archived docs from prior version
│   ├── PROJ-ARCH.md                #   High-level architecture
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-SCHEMA.md              #   Database schema documentation
│   └── winnower-design.md          #   Winnower agent design document
├── project-management/             # Planning & specs → [layout/project-management.md](layout/project-management.md)
│   ├── personas/                   #   Persona definitions with index.yaml
│   ├── user-stories/               #   147 user stories with index.yaml
│   ├── PRDs/                       #   Product requirement documents (PRD-001–017)
│   └── TODO/                       #   Backlog items
├── conventions/                    # NPL convention YAML definitions
├── npl/                            # NPL language specifications (YAML + Markdown)
├── agents/                         # TDD agent definitions (npl-*.md, incl. npl-winnower)
├── commands/                       # Claude Code slash commands (8 commands)
├── sub-agent-prompts/              # Reusable prompts for parallel agent spawning
├── scripts/                        # Operational scripts (port forwarding, etc.)
├── gh-pages                        # GitHub Pages submodule (static site)
├── liquibase/                      # Database migrations (Liquibase YAML changelogs)
│   ├── changelogs/                 #   Migration changesets (001–008)
│   ├── liquibase.properties        #   Connection config
│   └── liquibase.properties.example#   Template for local setup
├── docker/                         # Docker configuration
│   └── postgres-init/              #   PostgreSQL init scripts
├── tools/                          # Utility scripts (git_tree, git_dump, markdown, validators)
├── worktrees/                      # Git worktrees (gitignored, extended workspace)
│   ├── main/                       #   Main branch with full NPL framework
│   ├── npl-update/                 #   Update worktree
│   ├── redo/                       #   Redo worktree
│   └── take-3/                     #   Take-3 worktree
├── .claude/                        # Claude Code configuration
│   ├── agents/                     #   Agent definitions (symlinks + local)
│   ├── commands/                   #   Slash command definitions
│   ├── worktrees/                  #   Claude Code worktree state
│   └── settings.local.json         #   Local settings (gitignored)
├── .prd/                           # PRD workspace
├── .tmp/                           # Temporary/scratch files (gitignored)
├── .envrc                          # direnv — loads environment
├── .gitmodules                     # Git submodule definitions (gh-pages)
├── .mise.toml                      # mise task runner configuration
├── .python-version                 # Python version (3.13)
├── .tool-versions                  # Tool version management
├── debug-command.sh                # Debug/diagnostic shell script
├── docker-compose.yaml             # Local dev services (PostgreSQL)
├── package-lock.json               # Node package lock (frontend deps)
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

Agents defined in `agents/` (mirrored in `.claude/agents`):

| Agent | Purpose |
|-------|---------|
| `npl-idea-to-spec` | Transform ideas to personas + user stories |
| `npl-prd-editor` | Generate PRD documents from user stories |
| `npl-tdd-tester` | Create comprehensive test suites |
| `npl-tdd-coder` | Implement features using TDD cycle |
| `npl-tdd-debugger` | Diagnose and fix test failures |
| `npl-winnower` | Response winnowing and quality filtering |
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
