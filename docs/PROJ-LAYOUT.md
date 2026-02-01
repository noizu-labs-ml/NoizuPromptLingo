# Project Layout

```
NoizuPromptLingo/
├── src/                        # Application source code
│   ├── npl_mcp/                #   Main NPL MCP package
│   │   ├── __init__.py         #     Package init
│   │   ├── __main__.py         #     Module entry point
│   │   └── launcher.py         #     CLI entry point with server management
│   └── mcp.py                  #   Minimal FastMCP hello-world server
├── tests/                      # Test suites
│   └── test_mcp_server.py      #   MCP server tests
├── docs/                       # Documentation
│   └── PROJ-LAYOUT.md          #   This file
├── commands/                   # Claude Code slash command definitions
│   ├── update-arch-doc.md      #   PROJ-ARCH.md maintenance guide
│   └── update-layout-doc.md    #   PROJ-LAYOUT.md maintenance guide
├── .claude/                    # Claude Code configuration
│   ├── commands/               #   Symlinks to commands/ (for Claude Code)
│   └── settings.local.json     #   Local Claude Code settings (gitignored)
├── agents/                     # Agent definitions (placeholder)
├── .mise.toml                  # mise task runner configuration
├── .python-version             # Python version (3.13)
├── .gitignore                  # Git ignore patterns
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
| `src/npl_mcp/launcher.py` | Full NPL MCP server with CLI flags (`--status`, `--stop`, `--config`, `--test`) |

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

## Generated Directories (gitignored)

| Directory | Purpose |
|-----------|---------|
| `.venv/` | Virtual environment created by `uv sync` |
| `htmlcov/` | HTML coverage reports from pytest-cov |
| `.pytest_cache/` | pytest cache |
| `worktrees/` | Git worktrees (frontend lives here when present) |
