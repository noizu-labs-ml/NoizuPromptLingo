# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (launcher, markdown, meta_tools, npl, pm_tools, browser, storage, web + stubs)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 680+ tests (markdown, NPL, PM tools, meta tools, browser tools)
├── docs/                   # Architecture, reference, layout, pending, prior-version
├── project-management/     # Personas, 150+ user stories, 16 PRDs, TODOs
├── npl/                    # NPL language specifications (YAML + Markdown)
├── skills/                 # Skill definitions (4 domains)
├── agents/                 # TDD agent definitions (npl-*.md)
├── commands/               # Claude Code slash commands
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── scripts/                # Operational scripts (port forwarding)
├── liquibase/              # Database migrations (Liquibase YAML)
├── docker/                 # Docker config (PostgreSQL init)
├── tools/                  # Utility scripts (git, markdown, validators)
├── worktrees/              # Git worktrees (main, npl-update, redo)
├── .claude/                # Claude Code config (symlinks to commands/, agents/)
├── .prd/                   # PRD workspace
├── .tmp/                   # Scratch files (gitignored)
├── .envrc                  # direnv config
├── .mise.toml              # mise task runner
├── docker-compose.yaml     # Local PostgreSQL at localhost:5111
├── pyproject.toml          # Package metadata + dependencies
└── CLAUDE.md               # Claude Code instructions
```
