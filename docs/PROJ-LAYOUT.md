# Project Layout

```
NoizuPromptLingo/
├── src/                        # Application source code
│   ├── npl_mcp/                #   Main NPL MCP package
│   │   ├── __init__.py         #     Package init
│   │   ├── launcher.py         #     CLI entry point with server management
│   │   ├── __main__.py         #     Module entry point
│   │   └── __pycache__/        #     Python cache
│   └── mcp.py                  #   Minimal FastMCP hello-world server
├── tests/                      # Test suites
├── docs/                       # Documentation
│   ├── arch/                   #   Architecture docs (agent orchestration, assumptions)
│   ├── claude/                 #   Claude Code tooling documentation
│   ├── layout/                 #   Extended layout documentation
│   ├── reference/              #   Reference documentation (e.g., MCP)
│   ├── PROJ-ARCH.md            #   High-level architecture
│   └── PROJ-LAYOUT.md          #   This file
├── project-management/         # Project management and planning
│   ├── personas/               #   Persona definitions with index.yaml
│   ├── user-stories/           #   User story definitions with index.yaml
│   ├── PRDs/                   #   Product requirement documents
│   ├── prd.md                  #   Product requirements document
│   ├── prd.summary.md          #   PRD summary
│   ├── user-stories.md         #   User stories overview
│   └── user-stories.summary.md #   User stories summary
├── agents/                     # TDD agent definitions
│   ├── idea-to-spec.md         #   Idea-to-specification agent
│   ├── prd-editor.md           #   PRD editing agent
│   ├── tdd-coder.md            #   TDD implementation agent
│   ├── tdd-debugger.md         #   TDD debugging agent
│   ├── tdd-tester.md           #   TDD test creation agent
│   ├── npl-tasker-fast.md      #   Fast model task execution
│   ├── npl-tasker-haiku.md     #   Haiku model task execution
│   ├── npl-tasker-opus.md      #   Opus model task execution
│   ├── npl-tasker-sonnet.md    #   Sonnet model task execution
│   └── npl-tasker-ultra.md         #   Ultra model task execution
├── commands/                   # Claude Code slash commands
│   ├── update-arch-doc.md      #   PROJ-ARCH.md maintenance guide
│   ├── update-layout-doc.md    #   PROJ-LAYOUT.md maintenance guide
│   ├── track-assumptions.md    #   Response instructions
│   ├── annotate.md             #   Footnote annotation tool
│   ├── reflect.md              #   Response reflection tool
│   └── guest.md                #   Welcome environment skill
├── tools/                      # Utility scripts
│   ├── __init__.py             #   Package init
│   ├── git_tree.py             #   Tree generation utility
│   ├── git_dump.py             #   Git dump utility
│   ├── lib/                    #   Shared utilities
│   └── __pycache__/            #   Python cache
├── .claude/                    # Claude Code configuration
│   ├── commands -> ../commands # Symlink to commands/
│   ├── agents -> ../agents     # Symlink to agents/
│   └── settings.local.json     # Local settings (gitignored)
├── worktrees/                  # Git worktrees (extended workspace)
│   ├── main/                   #   Main worktree with full NPL framework
│   │   ├── .npl/               #     NPL metadata (personas, prds)
│   │   ├── core/               #     NPL core framework (agents, commands, prompts, schema)
│   │   ├── demo/               #     Demo projects
│   │   └── mcp-server/         #     Full MCP server implementation
│   └── npl-update/             #   Update worktree
├── .tmp/                       # Temporary files (gitignored)
├── .venv/                      # Virtual environment (gitignored)
├── .mise.toml                  # mise task runner configuration
├── .python-version             # Python version (3.13)
├── .gitignore                  # Git ignore patterns
├── .coverage                   # pytest coverage data (gitignored)
├── pyproject.toml              # Project metadata and dependencies
├── uv.lock                     # Dependency lock file
├── CLAUDE.md                   # Claude Code instructions
├── LICENSE                     # Project license
└── README.md                   # Start here
```

## Key Entry Points

| File | Description |
|------|-------------|
| `src/mcp.py` | Minimal FastMCP server exposing a single `hello` tool (SSE on 127.0.0.1:8765) |
| `worktrees/main/mcp-server/` | Full NPL MCP server with comprehensive tooling |
| `worktrees/main/core/` | NPL persona framework and agent definitions |

## Console Scripts

| Script | Module | Description |
|--------|--------|-------------|
| `npl-mcp` | `npl_mcp.launcher:main` | Run the full NPL MCP server |

## Configuration Files

| File | Purpose |
|------|---------|
| `.mise.toml` | Task definitions for mise (`run`, `test`, `test-coverage`, etc.) |
| `.python-version` | Specifies Python 3.13 for tools like pyenv/mise |
| `pyproject.toml` | Package metadata, dependencies, build config |
| `uv.lock` | Locked dependency versions |

## Documentation Structure

| Directory | Contents |
|-----------|----------|
| `docs/arch/` | Agent orchestration, assumptions (with .summary.md files) |
| `docs/claude/` | Claude Code tooling documentation (tools.md and tools/ subdirectory) |
| `docs/claude/tools/` | Tool category docs (agents, command-exec, file-ops, planning, search, task-tracking, user-interaction, web-ops) |
| `docs/layout/` | Extended layout documentation (user-stories.md) |
| `docs/reference/` | Reference documentation (mcp.md) |
| `project-management/personas/` | Persona definitions with index.yaml |
| `project-management/user-stories/` | 110+ user stories (US-001 through US-110) with index.yaml |
| `project-management/PRDs/` | Product requirement documents (PRD-001 through PRD-014) |
| `worktrees/main/core/` | Extended NPL framework (agents, commands, prompts, schema, specifications, etc.) |

## TDD Agent Workflow

The project uses a multi-agent TDD system with agents defined in `agents/`:

| Agent | Purpose |
|-------|---------|
| `idea-to-spec` | Transform ideas to personas + user stories |
| `prd-editor` | Generate PRD documents from user stories |
| `tdd-tester` | Create comprehensive test suites |
| `tdd-coder` | Implement features using TDD cycle |
| `tdd-debugger` | Diagnose and fix test failures |

## Generated Directories (gitignored)

| Directory | Purpose |
|-----------|---------|
| `.venv/` | Virtual environment created by `uv sync` |
| `.tmp/` | Temporary files for review instructions and agent work |
| `htmlcov/` | HTML coverage reports from pytest-cov |
| `.pytest_cache/` | pytest cache |
| `.ruff_cache/` | Ruff linting cache |
| `.coverage` | pytest coverage data file |