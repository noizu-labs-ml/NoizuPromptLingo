# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (launcher, markdown, meta_tools, npl, pm_tools, instructions, tool_sessions, browser, storage, artifacts, chat, sessions, tasks, web)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 27 test files incl. conftest.py (shared fixtures), test_catalog_migration.py (FastMCP integration), test_mcp_server.py (e2e)
├── docs/                   # Architecture, reference, layout, schema, agents, claude, pending, prior-version, winnower design
├── project-management/     # Personas, 147 user stories, 21 PRDs (001–017), TODOs
├── conventions/            # NPL convention YAML definitions (source of truth)
├── npl/                    # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                 # TDD agent definitions (npl-*.md, incl. npl-winnower)
├── commands/               # Claude Code slash commands (8 commands)
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── gh-pages                # GitHub Pages submodule (static site)
├── liquibase/              # Database migrations (Liquibase YAML, changesets 001–013)
├── docker/                 # Docker config (PostgreSQL init)
├── tools/                  # Utility scripts (git, markdown, validators)
├── worktrees/              # Git worktrees (gitignored: main, npl-update, redo, take-3)
├── .claude/                # Claude Code config (agents/, commands/, worktrees/, settings)
├── .prd/                   # PRD workspace
├── .tmp/                   # Scratch files (gitignored)
├── .envrc                  # direnv config
├── .gitmodules             # Git submodule definitions (gh-pages)
├── .mise.toml              # mise task runner
├── debug-command.sh        # Debug/diagnostic script
├── docker-compose.yaml     # Local PostgreSQL at localhost:5111
├── package-lock.json       # Node package lock (frontend deps)
├── pyproject.toml          # Package metadata + dependencies
└── CLAUDE.md               # Claude Code instructions
```
