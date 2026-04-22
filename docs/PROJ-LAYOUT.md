# Project Layout

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
│   │   └── launcher.py             #     CLI entry point with server management
│   ├── npl_persona/                #   Persona simulation CLI (analysis, journal, knowledge, teams, templates)
│   └── mcp.py                      #   Minimal FastMCP hello-world server
├── frontend/                       # Next.js web UI (React/TypeScript/Tailwind)
│   ├── app/                        #   App router (layout, page, globals)
│   ├── components/                 #   React components
│   │   ├── modals/                 #     QuickCreateModal (global create flow)
│   │   ├── primitives/             #     Tokens: Button/Input/Toast/Badge/… (30+ components)
│   │   ├── composites/             #     FilterBar/DetailHeader/ListRow/TabBar
│   │   ├── forms/                  #     SearchBox/FilterListbox
│   │   └── shell/                  #     AppShell/TopBar/Sidebar/CommandPalette
│   ├── lib/                        #   API client + utilities
│   │   ├── api/                    #     Facade + hybrid/rest/mock impls + types
│   │   └── utils/                  #     format, badges, focusRing helpers
│   ├── package.json                #   Node dependencies
│   └── tsconfig.json               #   TypeScript config
├── tests/                          # Test suites → [layout/tests.md](layout/tests.md)
│   ├── conftest.py                 #   Shared fixtures (_mcp_app session scope, cache clearing)
│   └── 35 test files               #   Unit/integration/e2e (catalog, browser, markdown, PM, sessions, etc.)
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
├── conventions/                    # NPL convention YAML definitions (source of truth for NPLSpec + load_npl)
├── npl/                            # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                         # Agent definitions (30+ agents: TDD, taskers, persona, coordinator, etc.)
├── commands/                       # Claude Code slash commands (14 commands)
├── sub-agent-prompts/              # Reusable prompts for parallel agent spawning
├── scripts/                        # Operational scripts (port forwarding, etc.)
├── gh-pages                        # GitHub Pages submodule (static site)
├── liquibase/                      # Database migrations (Liquibase YAML changelogs)
│   ├── changelogs/                 #   Migration changesets (001–017)
│   ├── liquibase.properties        #   Connection config (gitignored)
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

## Agent Definitions

Agents defined in `agents/` (mirrored in `.claude/agents`):

| Category | Agents | Purpose |
|----------|--------|---------|
| TDD Pipeline | `npl-idea-to-spec`, `npl-prd-editor`, `npl-tdd-tester`, `npl-tdd-coder`, `npl-tdd-debugger` | Feature specification through implementation |
| Taskers | `npl-tasker`, `npl-tasker-haiku/fast/sonnet/opus/ultra` | Task execution at various cost/capability levels |
| Authoring | `npl-author`, `npl-marketing-writer`, `npl-technical-writer` | Content generation and NPL prompt authoring |
| Analysis | `npl-winnower`, `npl-gopher-scout`, `npl-thinker`, `npl-grader` | Code exploration, reasoning, validation |
| Persona | `npl-persona`, `npl-persona-manager` | Character simulation and persona management |
| Coordination | `npl-project-coordinator`, `npl-prd-manager` | Task orchestration and PRD lifecycle |
| Domain | `npl-sql-architect`, `npl-build-master`, `npl-cpp-modernizer`, `npl-perf-profiler`, `npl-threat-modeler` | Specialized domain expertise |
| Other | `npl-fim`, `npl-templater`, `nimps` | Visualization, template management |

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
