# PRD: NPL Framework Pip Package Structure
Product Requirements Document for packaging the NPL Framework as an installable Python package.

**version**
: 1.0

**status**
: draft

**owner**
: NPL Framework Team

**last-updated**
: 2025-12-10

**stakeholders**
: Framework users, MCP server users, AI agent developers

---

## Executive Summary

The NPL Framework currently lacks proper Python packaging infrastructure. Users must clone the repository, manually configure PATH variables, and create symlinks to use CLI tools. This PRD defines requirements for packaging NPL as a pip-installable package (`npl-framework`) that bundles all components including the MCP server, persona library, and CLI tools.

The goal is single-command installation (`pip install npl-framework`) that provides immediate access to all 7 CLI tools while maintaining backward compatibility with existing manual installations.

---

## Problem Statement

### Current State

Users must perform multiple manual steps to use NPL:
- Clone the repository
- Add `core/scripts/` to PATH manually
- Create symlinks or aliases for CLI tools
- Manually manage dependencies across Python scripts
- Configure `PYTHONPATH` for internal library imports (e.g., `npl_persona`)

The MCP server at `mcp-server/` is already properly packaged but isolated from the main framework.

### Desired State

A single `pip install npl-framework` command that:
- Installs all CLI tools as executable commands
- Bundles the MCP server as a subpackage
- Includes all data files (agents, prompts, specifications)
- Works alongside manual installations without conflicts

### Gap Analysis

| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Installation method | Manual clone + PATH setup | `pip install npl-framework` | No pyproject.toml at root |
| CLI availability | Requires PATH modification | Available immediately after pip install | No entry points defined |
| Library imports | Requires PYTHONPATH manipulation | Standard `import npl_*` | No src/ layout |
| Data files | Accessed via relative paths | Bundled with package_data | No MANIFEST.in |
| MCP integration | Separate package | Bundled subpackage | Packages not unified |

---

## Goals and Objectives

### Business Objectives

1. Reduce time-to-first-use from 15+ minutes to under 2 minutes
2. Enable standard Python ecosystem distribution via PyPI
3. Maintain single source of truth for all NPL components

### User Objectives

1. Install all NPL tools with one command
2. Use CLI tools without PATH configuration
3. Import NPL libraries in Python scripts without path manipulation

### Non-Goals

- Breaking changes to existing CLI interfaces
- Removing support for development/editable installs
- Creating separate packages for each component (rejected: single bundled package chosen)
- Support for Python < 3.10

---

## Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Installation success rate | N/A | >99% | Release | CI testing on Python 3.10, 3.11, 3.12 |
| Time to first CLI execution | 15+ min | <2 min | Release | User testing |
| Backward compatibility | N/A | 100% | Release | Existing manual installs continue working |

---

## User Personas

### Package User (Primary)

**demographics**
: Python developer, uses pip/uv for package management

**goals**
: Quick installation, standard import patterns, reliable CLI tools

**frustrations**
: Manual PATH configuration, dependency management, relative import issues

**quote**
: "I just want `pip install` to work and give me the CLI tools."

### Framework Developer

**demographics**
: Contributor to NPL, needs editable installs

**goals**
: Easy development setup, tests run against installed package

**frustrations**
: Dual maintenance of scripts and entry points

**quote**
: "I need `pip install -e .` to reflect my changes immediately."

---

## Functional Requirements

### FR-001: Root pyproject.toml Configuration

**priority**: P0

**description**
: Create a `pyproject.toml` at repository root using hatchling build system, defining package metadata and build configuration.

**acceptance-criteria**
: - [ ] File exists at `/pyproject.toml`
: - [ ] Package name is `npl-framework`
: - [ ] Requires Python >=3.10
: - [ ] Uses `hatchling` as build backend (matching existing MCP server)
: - [ ] Defines version following semantic versioning
: - [ ] Includes project metadata (description, readme, license, authors)

**rationale**
: Hatchling is already used by the MCP server, maintaining consistency. Python 3.10 provides modern features and type hint support.

---

### FR-002: Source Layout Structure

**priority**: P0

**description**
: Reorganize code into a `src/` layout with three top-level packages.

**acceptance-criteria**
: - [ ] Create `src/npl_framework/` as main package
: - [ ] Create `src/npl_framework/__init__.py` with version and public API
: - [ ] Create `src/npl_framework/scripts/` for CLI tool modules
: - [ ] Create `src/npl_framework/data/` for bundled markdown files
: - [ ] Move MCP server code to `src/npl_mcp/` (from `mcp-server/src/npl_mcp/`)
: - [ ] Move persona library to `src/npl_persona/` (from `core/lib/npl_persona/`)
: - [ ] Each package has proper `__init__.py` with version

**rationale**
: The `src/` layout is the modern Python standard, preventing accidental imports from working directory.

**dependencies**
: None

**notes**
: Original locations (`mcp-server/`, `core/lib/`) should remain as symlinks or be preserved for backward compatibility during transition.

---

### FR-003: Console Script Entry Points

**priority**: P0

**description**
: Define entry points for all 7 CLI tools in pyproject.toml.

**acceptance-criteria**
: - [ ] `npl-load` entry point maps to `npl_framework.scripts.npl_load:main`
: - [ ] `npl-persona` entry point maps to `npl_framework.scripts.npl_persona:main`
: - [ ] `npl-worklog` entry point maps to `npl_framework.scripts.npl_worklog:main`
: - [ ] `npl-fim-config` entry point maps to `npl_framework.scripts.npl_fim_config:main`
: - [ ] `dump-files` entry point maps to `npl_framework.scripts.dump_files:main`
: - [ ] `git-tree` entry point maps to `npl_framework.scripts.git_tree:main`
: - [ ] `git-tree-depth` entry point maps to `npl_framework.scripts.git_tree_depth:main`
: - [ ] All entry points executable after `pip install`
: - [ ] Include existing MCP entry points (`npl-mcp`, `npl-mcp-web`, `npl-mcp-unified`, `npl-mcp-launcher`)

**rationale**
: Entry points are the standard way to create CLI commands from Python packages.

**dependencies**
: FR-002 (source layout must exist)

**notes**
: Bash scripts (`dump-files`, `git-tree`, `git-tree-depth`) must be converted to Python or wrapped.

---

### FR-004: Data File Bundling

**priority**: P0

**description**
: Include all markdown data files in the package distribution.

**acceptance-criteria**
: - [ ] `core/agents/*.md` files accessible via `importlib.resources`
: - [ ] `core/commands/*.md` files accessible via `importlib.resources`
: - [ ] `core/prompts/*.md` files accessible via `importlib.resources`
: - [ ] `core/specifications/*.md` files accessible via `importlib.resources`
: - [ ] `core/npl/*.md` files (NPL syntax definitions) accessible
: - [ ] Data files included in wheel distribution
: - [ ] `npl-load` can locate bundled data files

**rationale**
: Data files are essential for `npl-load` functionality and agent definitions.

**dependencies**
: FR-002 (data files go in `src/npl_framework/data/`)

**implementation-notes**
```toml
[tool.hatch.build.targets.wheel]
packages = ["src/npl_framework", "src/npl_mcp", "src/npl_persona"]

[tool.hatch.build.targets.wheel.force-include]
"core/agents" = "npl_framework/data/agents"
"core/commands" = "npl_framework/data/commands"
"core/prompts" = "npl_framework/data/prompts"
"core/specifications" = "npl_framework/data/specifications"
"core/npl" = "npl_framework/data/npl"
```

---

### FR-005: Dependency Management

**priority**: P0

**description**
: Define all package dependencies in pyproject.toml with appropriate version constraints.

**acceptance-criteria**
: - [ ] Core dependencies: `pyyaml>=6.0`
: - [ ] MCP dependencies bundled: `fastmcp>=0.1.0`, `aiosqlite>=0.19.0`, `fastapi>=0.104.0`, `uvicorn>=0.24.0`, `httpx>=0.25.0`, `pillow>=10.0`
: - [ ] All dependencies have minimum version pins
: - [ ] No upper bound constraints unless required for compatibility
: - [ ] Package installs successfully in fresh virtual environment

**rationale**
: Proper dependency management ensures reproducible installations.

**dependencies**
: FR-001

---

### FR-006: Optional Extras

**priority**: P1

**description**
: Define optional dependency groups for development and specialized use cases.

**acceptance-criteria**
: - [ ] `[dev]` extra includes: `pytest>=7.4.0`, `pytest-asyncio>=0.21.0`, `ruff`, `mypy`
: - [ ] `[docs]` extra includes documentation build dependencies (if applicable)
: - [ ] Extras installable via `pip install npl-framework[dev]`

**rationale**
: Keeps base installation minimal while supporting development workflows.

**dependencies**
: FR-005

---

### FR-007: Path Resolution Updates

**priority**: P0

**description**
: Update `npl-load` and other tools to resolve data files from both installed package and development locations.

**acceptance-criteria**
: - [ ] `npl-load` checks `importlib.resources` for bundled data first
: - [ ] Falls back to environment variables (`NPL_HOME`, etc.)
: - [ ] Falls back to relative paths for development
: - [ ] Existing `RESOURCE_CONFIG` patterns respected
: - [ ] Search order documented in code comments

**rationale**
: Supports both installed and development use cases without configuration changes.

**dependencies**
: FR-002, FR-004

**implementation-notes**
```python
def get_data_path(resource_type: str) -> Path:
    """Get path to data files, preferring installed package."""
    try:
        import importlib.resources as resources
        with resources.files('npl_framework.data') as data_dir:
            candidate = data_dir / resource_type
            if candidate.exists():
                return candidate
    except (ImportError, FileNotFoundError):
        pass
    # Fall back to environment/relative paths
    return _legacy_path_resolution(resource_type)
```

---

### FR-008: Backward Compatibility Layer

**priority**: P1

**description**
: Ensure existing manual installations and development workflows continue working.

**acceptance-criteria**
: - [ ] `core/scripts/` executables remain functional
: - [ ] `core/lib/npl_persona/` importable via legacy path
: - [ ] `mcp-server/` directory structure preserved
: - [ ] Environment variables still override package defaults
: - [ ] No breaking changes to CLI interfaces

**rationale**
: Users should not be forced to change workflows during migration period.

**dependencies**
: FR-007

---

### FR-009: Python Module Conversion for Bash Scripts

**priority**: P1

**description**
: Convert or wrap bash scripts as Python modules for cross-platform compatibility and entry point support.

**acceptance-criteria**
: - [ ] `dump-files` has Python equivalent in `npl_framework.scripts.dump_files`
: - [ ] `git-tree` has Python equivalent in `npl_framework.scripts.git_tree`
: - [ ] `git-tree-depth` has Python equivalent in `npl_framework.scripts.git_tree_depth`
: - [ ] Python versions produce identical output to bash originals
: - [ ] Git operations use `subprocess` with proper error handling
: - [ ] Works on Windows, macOS, and Linux

**rationale**
: Python entry points cannot directly invoke bash scripts; Python wrappers enable cross-platform CLI tools.

**dependencies**
: FR-003

---

## Non-Functional Requirements

### NFR-001: Installation Performance

**priority**: P1

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| Package download size | <5MB | Built wheel size |
| Installation time | <30s | Fresh venv install |

---

### NFR-002: Platform Support

**priority**: P0

**platforms**
: - macOS (arm64, x86_64)
: - Linux (x86_64, arm64)
: - Windows 10/11 (x86_64)

**python-versions**
: - Python 3.10
: - Python 3.11
: - Python 3.12
: - Python 3.13 (when stable)

---

### NFR-003: Distribution Channels

**priority**: P2

**channels**
: - PyPI (primary)
: - GitHub Releases (wheels)
: - Source tarball

---

## Constraints and Assumptions

### Constraints

**technical**
: - Must use hatchling build system (consistency with MCP server)
: - Cannot change CLI command names (backward compatibility)
: - Must support Python 3.10+ only

**business**
: - Single package approach (no separate `npl-mcp` on PyPI)

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| Users have pip/uv available | Cannot install | Document alternative methods |
| Git is available for bash script wrappers | `git-tree` tools fail | Provide graceful error messages |
| Users can write to site-packages | Installation fails | Document venv usage |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| Path resolution breaks in edge cases | Medium | High | Comprehensive test suite for path resolution | Dev |
| Bash script conversion introduces bugs | Medium | Medium | Diff testing against original scripts | Dev |
| Package size too large with all data | Low | Low | Lazy loading, exclude non-essential files | Dev |
| Version conflicts with standalone npl-mcp | Low | High | Document migration path, deprecate standalone | Dev |

---

## Timeline and Milestones

### Phase 1: Core Packaging (MVP)

**scope**
: - Root pyproject.toml
: - Basic src/ layout
: - Entry points for Python scripts only
: - Data file bundling

**success-criteria**
: `pip install -e .` works, `npl-load` and `npl-persona` executable

### Phase 2: Full CLI Support

**scope**
: - Bash script Python conversions
: - All 7 CLI tools as entry points
: - MCP server integration
: - Optional extras

**success-criteria**
: All commands work identically to current scripts

### Phase 3: Distribution

**scope**
: - PyPI publication
: - CI/CD for releases
: - Documentation updates

**success-criteria**
: `pip install npl-framework` works from PyPI

---

## Implementation Checklist

### Directory Structure

```
npl/
+-- pyproject.toml              # NEW: Root package configuration
+-- MANIFEST.in                 # NEW: Source distribution includes
+-- src/                        # NEW: Source layout root
|   +-- npl_framework/
|   |   +-- __init__.py
|   |   +-- scripts/
|   |   |   +-- __init__.py
|   |   |   +-- npl_load.py     # From core/scripts/npl-load
|   |   |   +-- npl_persona.py  # Wrapper for npl_persona.cli
|   |   |   +-- npl_worklog.py  # From core/scripts/npl-worklog
|   |   |   +-- npl_fim_config.py
|   |   |   +-- dump_files.py   # Python conversion
|   |   |   +-- git_tree.py     # Python conversion
|   |   |   +-- git_tree_depth.py
|   |   +-- data/               # Symlinks or copies at build time
|   |       +-- agents/         # -> core/agents/
|   |       +-- commands/       # -> core/commands/
|   |       +-- prompts/        # -> core/prompts/
|   |       +-- specifications/ # -> core/specifications/
|   |       +-- npl/            # -> core/npl/
|   +-- npl_mcp/                # From mcp-server/src/npl_mcp/
|   +-- npl_persona/            # From core/lib/npl_persona/
+-- core/                       # PRESERVED: Original locations
+-- mcp-server/                 # PRESERVED: Original MCP server
+-- tests/                      # NEW: Package tests
```

### pyproject.toml Template

```toml
[project]
name = "npl-framework"
version = "0.1.0"
description = "Natural Prompt Language Framework - AI agent tooling and prompt management"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [
    {name = "NPL Framework Team"}
]
keywords = ["npl", "ai", "agents", "prompts", "mcp"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "pyyaml>=6.0",
    "fastmcp>=0.1.0",
    "aiosqlite>=0.19.0",
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0",
    "httpx>=0.25.0",
    "pillow>=10.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
]

[project.scripts]
npl-load = "npl_framework.scripts.npl_load:main"
npl-persona = "npl_framework.scripts.npl_persona:main"
npl-worklog = "npl_framework.scripts.npl_worklog:main"
npl-fim-config = "npl_framework.scripts.npl_fim_config:main"
dump-files = "npl_framework.scripts.dump_files:main"
git-tree = "npl_framework.scripts.git_tree:main"
git-tree-depth = "npl_framework.scripts.git_tree_depth:main"
# MCP entry points
npl-mcp = "npl_mcp.server:main"
npl-mcp-web = "npl_mcp.combined:main"
npl-mcp-unified = "npl_mcp.unified:main"
npl-mcp-launcher = "npl_mcp.launcher:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/npl_framework", "src/npl_mcp", "src/npl_persona"]

[tool.hatch.build.targets.wheel.force-include]
"core/agents" = "npl_framework/data/agents"
"core/commands" = "npl_framework/data/commands"
"core/prompts" = "npl_framework/data/prompts"
"core/specifications" = "npl_framework/data/specifications"
"core/npl" = "npl_framework/data/npl"
```

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:----|
| Should `npl-session` be renamed to `npl-worklog`? | CLI naming | Team | Before Phase 1 |
| Include `core/schema/*.sql` files? | Data completeness | Team | Before Phase 1 |
| Deprecation timeline for standalone mcp-server? | Migration planning | Team | Before Phase 3 |
| License file location and type? | Legal compliance | Team | Before Phase 3 |

---

## Appendix

### Glossary

**entry point**
: Python packaging mechanism that creates executable CLI commands

**src layout**
: Directory structure where packages live under `src/` to prevent import confusion

**hatchling**
: Modern Python build backend with good support for data files and src layouts

**wheel**
: Binary Python package format for fast installation

**editable install**
: Development installation where code changes take effect without reinstall (`pip install -e .`)

### References

- [Python Packaging User Guide](https://packaging.python.org/)
- [Hatchling Documentation](https://hatch.pypa.io/latest/)
- [PEP 517 - Build System Interface](https://peps.python.org/pep-0517/)
- [PEP 621 - Project Metadata](https://peps.python.org/pep-0621/)
- Existing MCP server: `mcp-server/pyproject.toml`

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-10 | NPL PRD Manager | Initial draft |
