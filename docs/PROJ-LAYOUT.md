# Project Layout

This document describes the directory structure and file organization of the Noizu Prompt Lingua (NPL) project.

## Root Structure

```
npl/
├── core/scripts/       # Utility scripts for development
├── docker/             # Docker initialization scripts
├── docs/               # Project documentation
├── liquibase/          # Database migrations
├── npl/                # NPL specification and language definitions
├── npl_mcp/            # MCP server implementation
├── tools/              # Python tooling and loaders
├── docker-compose.yaml # Container orchestration
├── pyproject.toml      # Root project configuration
└── uv.lock             # Dependency lock file
```

## Directory Details

### `docker/`

Docker-related configuration and initialization scripts:

```
docker/
└── postgres-init/
    └── 01-extensions.sql   # Installs pgvector and uuid-ossp extensions
```

### `liquibase/`

Database migration management:

```
liquibase/
├── liquibase.properties    # Connection configuration
└── changelogs/
    ├── changelog.yaml                     # Master changelog (includes others)
    └── changeset-001.initial-setup.yaml   # Initial schema setup
```

**Tables created:**
- `npl_metadata` - Configuration and state storage
- `npl_component` - NPL components with pgvector search
- `npl_sections` - Section definitions with pgvector search
- `npl_concepts` - Core NPL concepts with pgvector search

### `core/scripts/`

Development utility scripts for working with the codebase:

| Script | Purpose |
|--------|---------|
| `dump-files` | Recursively dump file contents with headers (respects .gitignore) |
| `git-tree` | Display directory tree using `tree` command |
| `git-tree-depth` | Show directory tree with nesting level indicators |
| `npl-fim-config` | NPL fill-in-middle configuration |
| `npl-load` | Load NPL definitions |
| `npl-persona` | Persona configuration utility |

### `npl/`

The core NPL specification files defining the prompt engineering framework:

```
npl/
├── npl.md                  # Main NPL specification document
├── npl.yaml                # YAML-based NPL definitions with taxonomy
├── syntax.yaml             # Core syntax element definitions
├── directives.md           # Directive patterns documentation
├── directives.extended.md  # Extended directive documentation
├── directives.yaml         # Directive YAML definitions
├── prefixes.yaml           # Prompt prefix definitions
├── prompt-sections.yaml    # Prompt section specifications
├── special-sections.yaml   # Special section definitions
└── instructional/          # Instructional documentation
    ├── agent.md            # Agent definition guide
    ├── agent.yaml          # Agent YAML definitions
    ├── declarations.md     # NPL declaration syntax
    ├── formatting.md       # Output formatting guide
    ├── formatting.extended.md
    ├── instructing.md      # Instructing patterns
    ├── instructing.extended.md
    ├── planning.md         # Planning and reasoning patterns
    ├── pumps.md            # Intuition pumps documentation
    └── pumps.extended.md
```

### `npl_mcp/`

MCP (Model Context Protocol) server implementation:

```
npl_mcp/
└── server.py           # FastMCP server with tools, resources, and prompts
```

### `tools/`

Python tooling for NPL processing:

```
tools/
├── npl_loader.py       # NPL YAML loader and formatter
├── tmp_npl_loader.py   # Database-driven loader (populate/refresh/output)
├── pyproject.toml      # Tools sub-package configuration
└── build/lib/          # Build artifacts
```

**CLI Commands:**
- `npl-loader` - Load YAML files and output formatted markdown
- `npl-db-loader` - Database operations (sync, output from DB)

## Configuration Files

### `pyproject.toml` (Root)

Defines the main `noizu-prompt-lingua` package:
- Python >=3.12 required
- Depends on `mcp[cli]>=1.25.0`
- Uses UV workspace with `tools/` as member

### `tools/pyproject.toml`

Defines the `npl-tools` sub-package:
- Provides `npl-loader` CLI command
- Depends on `pyyaml>=6.0`

## File Naming Conventions

- `.md` files: Human-readable documentation and specifications
- `.yaml` files: Machine-readable definitions with structured data
- `.extended.md` files: Extended documentation for advanced topics
- Python files: Implementation code and tooling

## Workspace Organization

The project uses a UV workspace structure:
- Root package: `noizu-prompt-lingua` (MCP server)
- Member package: `npl-tools` (CLI utilities in `tools/`)

This allows independent development and versioning of the MCP server and CLI tools while sharing the same repository.
