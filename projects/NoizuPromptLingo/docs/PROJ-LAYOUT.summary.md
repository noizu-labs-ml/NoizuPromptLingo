# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (agents, api, artifacts, browser, chat, executors, instructions, markdown, meta_tools, npl, pipes, pm_tools, scripts, sessions, skills, storage, tasks, tool_sessions, web)
├── src/npl_persona/        # Persona simulation CLI (analysis, journal, knowledge, teams, templates)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 35 test files incl. conftest.py (shared fixtures)
├── docs/                   # Architecture, reference, layout, schema, agents, claude, pending, prior-version
├── project-management/     # Personas, 151 user stories, PRDs (001–017), TODOs
├── conventions/            # NPL convention YAML definitions (source of truth)
├── npl/                    # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                 # Agent definitions (30+ agents: TDD, taskers, persona, coordinator, etc.)
├── commands/               # Claude Code slash commands (14 commands)
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── gh-pages                # GitHub Pages submodule (static site)
├── liquibase/              # Database migrations (Liquibase YAML, changesets 001–017)
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
