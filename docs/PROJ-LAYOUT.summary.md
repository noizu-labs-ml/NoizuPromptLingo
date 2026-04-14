# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (launcher, markdown, meta_tools, npl, pm_tools, instructions, tool_sessions, browser, storage, web + stubs)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 25 test files (markdown, NPL, PM tools, meta tools, browser, instructions, sessions)
├── docs/                   # Architecture, reference, layout, schema, agents, claude, pending, prior-version, winnower design
├── project-management/     # Personas, 147 user stories, 21 PRDs (001–017), TODOs
├── conventions/            # NPL convention YAML definitions
├── npl/                    # NPL language specifications (YAML + Markdown)
├── agents/                 # TDD agent definitions (npl-*.md, incl. npl-winnower)
├── commands/               # Claude Code slash commands (8 commands)
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── gh-pages                # GitHub Pages submodule (static site)
├── liquibase/              # Database migrations (Liquibase YAML, changesets 001–008)
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
