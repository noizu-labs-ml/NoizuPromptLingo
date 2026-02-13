# Project Layout Summary

```
NoizuPromptLingo/
├── src/npl_mcp/            # Main package (launcher, markdown, meta_tools, npl, pm_tools, web + stubs)
├── src/mcp.py              # Minimal FastMCP hello-world server
├── frontend/               # Next.js web UI (React/TypeScript/Tailwind)
├── tests/                  # 619+ tests (markdown, NPL, PM tools, meta tools)
├── docs/                   # Architecture, reference, layout, pending, prior-version
├── project-management/     # Personas, 130+ user stories, 17 PRDs, TODOs
├── npl/                    # NPL language specifications (YAML + Markdown)
├── skills/                 # Skill definitions (4 domains)
├── agents/                 # TDD agent definitions (npl-*.md)
├── commands/               # Claude Code slash commands
├── sub-agent-prompts/      # Reusable prompts for parallel agents
├── liquibase/              # Database migrations (Liquibase YAML)
├── docker/                 # Docker config (PostgreSQL init)
├── tools/                  # Utility scripts (git, markdown, validators)
├── worktrees/              # Git worktrees (main, npl-update)
├── .claude/                # Claude Code config (symlinks to commands/, agents/)
├── .tmp/                   # Scratch files (gitignored)
├── .envrc                  # direnv config
├── .mise.toml              # mise task runner
├── docker-compose.yaml     # Local PostgreSQL at localhost:5111
├── pyproject.toml          # Package metadata + dependencies
└── CLAUDE.md               # Claude Code instructions
```
