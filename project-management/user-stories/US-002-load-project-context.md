# User Story: Load Project-Specific Context

**ID**: US-002
**Persona**: P-001 (AI Agent)
**Priority**: Critical
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **load project-specific NPL components and conventions**,
So that **I understand the codebase structure, naming conventions, and project-specific rules before starting work**.

## Acceptance Criteria

- [ ] Can discover and load project NPL configuration files from standard locations (`.npl/`, `npl.yaml`, `.npl.yaml`)
- [ ] Can load project-specific syntax extensions and merge with core NPL syntax
- [ ] Can load coding style guides relevant to the project (e.g., `.npl/style.md`, `.npl/conventions.md`)
- [ ] Can identify project type (Python, TypeScript, etc.) from file extensions and load appropriate language-specific conventions
- [ ] Returns structured metadata including:
  - List of loaded configuration files with paths
  - Active syntax extensions
  - Active style guides
  - Detected project type(s)
  - Load timestamp
- [ ] Handles missing optional components gracefully without errors
- [ ] Logs warnings for expected-but-missing configuration files
- [ ] Successfully merges project context with core context from US-001

## Technical Approach

### Configuration Discovery
1. Search for configuration in order of precedence:
   - `.npl/config.yaml` (directory-based)
   - `npl.yaml` (root file)
   - `.npl.yaml` (hidden root file)
2. Load additional resources from `.npl/` directory if present:
   - `syntax/` - Project-specific syntax extensions
   - `conventions.md` - Coding conventions
   - `style.md` - Style guide
   - `agents.yaml` - Agent-specific configurations

### Project Type Detection
- Scan for language-specific files in priority order:
  - Python: `pyproject.toml`, `setup.py`, `*.py`
  - TypeScript/JavaScript: `package.json`, `tsconfig.json`, `*.ts`
  - Rust: `Cargo.toml`, `*.rs`
  - Go: `go.mod`, `*.go`
- Support multiple languages in polyglot projects

### Context Merging Strategy
- Project context supplements, not replaces, core components
- Project-specific rules override core defaults where conflicts exist
- Maintain inheritance chain: Core → Project → Task-specific

## Notes

- Should report which conventions are active after loading
- Configuration files use YAML for structured data, Markdown for documentation
- Failed loads of optional components should not block agent initialization

## Dependencies

- US-001 (core components should be loaded first)
- Project must have NPL configuration files

## Open Questions

- ~~How should conflicts between core and project conventions be resolved?~~ **RESOLVED**: Project-specific rules override core defaults
- ~~Should agents auto-detect project type from file extensions?~~ **RESOLVED**: Yes, with fallback to explicit configuration
- Should we support environment-specific overrides (dev vs prod)?
- What is the caching strategy for project context across multiple agent sessions?

## Related Tools & Commands

### NPL Tools (Planned)
- `npl_load_project` - Load project-specific context
- `npl_detect_project_type` - Identify programming languages in use
- `npl_merge_context` - Merge project context with core context

### Claude Code Tools
- `Read` - Read configuration files
- `Glob` - Discover configuration files by pattern
- `Bash` - Execute project type detection commands (e.g., `file`, `find`)

## Example Usage

```python
# Load project context after core context
result = npl_load_project(
    project_root="/path/to/project",
    auto_detect_type=True,
    include_optional=True
)

# Result structure:
{
    "project_type": ["python", "typescript"],
    "config_files": [".npl/config.yaml", "npl.yaml"],
    "syntax_extensions": ["python-async", "react-hooks"],
    "style_guides": [".npl/conventions.md"],
    "loaded_at": "2026-02-02T10:30:00Z"
}
```
