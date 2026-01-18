# Project Layout

This document describes the directory structure and file organization of the Noizu Prompt Lingua (NPL) project.

## Root Structure

```
npl/
├── core/scripts/       # Utility scripts for development
├── docker/             # Docker initialization scripts
├── docs/               # Project documentation
├── liquibase/          # Database migrations
├── npl/                # NPL specification YAML definitions
├── npl_mcp/            # MCP server implementation
├── tools/              # Python tooling and loaders
├── .gitignore          # Git exclusions
├── .python-version     # Python version specification
├── docker-compose.yaml # Container orchestration
├── LICENSE             # MIT License
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

**Container Services** (via `docker-compose.yaml`):
- `npl-timescaledb`: TimescaleDB 2.24.0-pg17 on port 5432
- `npl-redis`: Redis 8.4.0 on port 6379

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

The core NPL specification YAML files defining the prompt engineering framework:

```
npl/
├── npl.yaml                # Core NPL definitions, taxonomy, and section_order
├── syntax.yaml             # Core syntax element definitions
├── directives.yaml         # Directive YAML definitions
├── prefixes.yaml           # Prompt prefix definitions
├── prompt-sections.yaml    # Prompt section specifications
├── special-sections.yaml   # Special section definitions
├── declarations.yaml       # NPL declaration syntax definitions (instructional)
├── instructing.yaml        # Instructing patterns definitions (instructional)
└── pumps.yaml              # Intuition pumps definitions (instructional)
```

**npl.yaml Configuration:**
- `section_order.components`: Output order for component sections
- `section_order.instructional`: Output order for instructional sections

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
├── __init__.py         # Package marker
└── npl_loader.py       # NPL loader with YAML and database support
```

**CLI Command:** `npl-loader`
- Default: Output formatted markdown from database
- `--sync`: Sync YAML files to database (populate or refresh)
- `--yaml`: Output from YAML files instead of database
- `--list`: List all YAML files found with digests
- `--instructions`: Append instructional notes section to output

### `docs/`

Project documentation:

```
docs/
├── PROJ-ARCH.md            # Architecture documentation
├── PROJ-LAYOUT.md          # Directory structure documentation (this file)
└── instructional-blocks.md # Instructional content analysis
```

## Configuration Files

### `pyproject.toml`

Defines the `noizu-prompt-lingua` package:
- Python >=3.12 required
- Dependencies:
  - `mcp[cli]>=1.25.0` - MCP server framework
  - `pyyaml>=6.0` - YAML processing
  - `psycopg2-binary>=2.9.9` - PostgreSQL adapter
- Entry point: `npl-loader` CLI command
- Packages: `npl_mcp`, `tools`

## File Naming Conventions

- `.yaml` files: Machine-readable NPL definitions with structured data
- `.md` files: Human-readable documentation
- Python files: Implementation code and tooling
