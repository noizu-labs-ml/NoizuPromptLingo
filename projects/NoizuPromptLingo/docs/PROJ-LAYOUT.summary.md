# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (agents, api, artifacts, browser, chat, executors, instructions, markdown, meta_tools, npl, orchestration, pipes, pm_tools, scripts, sessions, skills, storage, tasks, tool_sessions, web)
├── src/npl_persona/        # Persona simulation CLI (analysis, journal, knowledge, teams, templates)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind) — includes cypress/ E2E
├── tests/                  # 40 test files incl. conftest.py (shared fixtures)
├── docs/                   # Architecture, reference, layout, schema, agents, claude, testing, pending, prior-version
├── project-management/     # Personas, 147 user stories, PRDs (001–018 + archive), TODOs + summary docs
├── conventions/            # NPL convention YAML definitions (source of truth)
├── npl/                    # Generated NPL artifacts (npl-full.md rendered from conventions/)
├── agents/                 # Agent definitions (31 primary agents + additional-agents/ + skeleton/)
├── commands/               # Claude Code slash commands (15 commands)
├── charts/                 # Helm charts (npl-mcp: Chart.yaml, values.yaml, templates/)
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── liquibase/              # Database migrations (Liquibase YAML, changesets 001–018)
├── docker/                 # Docker config (PostgreSQL init)
├── tools/                  # Utility scripts (git, markdown, validators, arize)
├── gh-pages                # GitHub Pages submodule (static site, branch: gh-pages)
├── .claude/                # Claude Code config (agents/, commands/, skills symlink, settings)
├── .agents/                # Alternate agent discovery path (skills symlink)
├── .codex/                 # Codex agent config (agents/)
├── .prd/                   # PRD workspace
├── .tmp/                   # Scratch files (gitignored)
├── .envrc                  # direnv config
├── .gitmodules             # Git submodule definitions (gh-pages)
├── .mise.toml              # mise task runner
├── AGENTS.md               # Codex instructions (mirrors CLAUDE.md)
├── CLAUDE.md               # Claude Code instructions
├── debug-command.sh        # Debug/diagnostic script
├── docker-compose.yaml     # Local PostgreSQL at localhost:5111
├── Dockerfile              # Container build definition
├── INSTALL.md              # Installation guide
├── Makefile                # Build and task automation
├── package-lock.json       # Node package lock (frontend deps)
├── pyproject.toml          # Package metadata + dependencies
├── README.md               # Start here
├── RESUME.md               # Project resumption / continuation notes
└── uv.lock                 # Dependency lock file
```
