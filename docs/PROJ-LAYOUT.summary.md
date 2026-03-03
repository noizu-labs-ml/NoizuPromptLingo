# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (launcher, markdown, meta_tools, npl, pm_tools, instructions, tool_sessions, browser, storage, web + stubs)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 25 test files (markdown, NPL, PM tools, meta tools, browser, instructions, sessions)
├── docs/                   # Architecture, reference, layout, agents, claude, pending, prior-version
├── project-management/     # Personas, 147 user stories, 21 PRDs (001–017), TODOs
├── conventions/            # NPL convention YAML definitions
├── npl/                    # NPL language specifications (YAML + Markdown)
├── skills/                 # Skill definitions (4 domains)
├── agents/                 # TDD agent definitions (npl-*.md)
├── commands/               # Claude Code slash commands
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── liquibase/              # Database migrations (Liquibase YAML)
├── docker/                 # Docker config (PostgreSQL init)
├── tools/                  # Utility scripts (git, markdown, validators)
├── wip/                    # Work-in-progress sub-project
├── worktrees/              # Git worktrees (main, npl-update, redo, take-3)
├── .claude/                # Claude Code config (agents/, commands/, settings)
├── .prd/                   # PRD workspace
├── .tmp/                   # Scratch files (gitignored)
├── .envrc                  # direnv config
├── .mise.toml              # mise task runner
├── docker-compose.yaml     # Local PostgreSQL at localhost:5111
├── pyproject.toml          # Package metadata + dependencies
└── CLAUDE.md               # Claude Code instructions
```
