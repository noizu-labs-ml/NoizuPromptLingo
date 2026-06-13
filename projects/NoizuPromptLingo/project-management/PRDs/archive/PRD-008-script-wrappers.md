# PRD: Script Wrappers

**PRD ID**: PRD-008
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

MCP tool wrappers for existing NPL command-line scripts enabling codebase exploration, content aggregation, and NPL framework resource loading. All tools enforce absolute path requirements to prevent ambiguity.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed
- **US-001**: Load NPL core components
- **US-002**: Load project-specific context
- **US-003**: Fetch web content as markdown
- **US-025**: Explore project file structure
- **US-047**: View database schema documentation

## Functional Requirements

### FR-001: File Content Aggregation (1 tool)
**Tool**: `dump_files(path, glob_filter)`
**Script**: core/scripts/dump-files
**Returns**: Concatenated file contents with headers
**Path Requirement**: Absolute paths only

```python
content = await dump_files(
    path="/home/user/project/docs",
    glob_filter="*.md"
)
```

### FR-002: Directory Tree Visualization (2 tools)
**Tools**: `git_tree(path)`, `git_tree_depth(path)`
**Scripts**: core/scripts/git-tree, core/scripts/git-tree-depth
**Returns**: Directory structure or depth analysis
**Path Requirement**: Absolute paths only

### FR-003: NPL Resource Loading (1 tool)
**Tool**: `npl_load(resource_type, items, skip)`
**Script**: core/scripts/npl-load (Python)
**Resource Types**: c (component), m (meta), s (style)
**Returns**: NPL content with tracking flags

```python
npl_syntax = await npl_load(
    resource_type="c",
    items="syntax,agent,formatting",
    skip="syntax"  # Already loaded
)
```

### FR-004: Web to Markdown (1 tool)
**Tool**: `web_to_md(url, timeout)`
**External API**: Jina Reader (https://r.jina.ai/)
**Environment**: JINA_API_KEY (optional)
**Returns**: Markdown-formatted page content

```python
markdown = await web_to_md(
    url="https://example.com/docs",
    timeout=30
)
```

## Dependencies
- **Internal**: Subprocess module
- **External**: dump-files (bash), git-tree (bash), git-tree-depth (bash), npl-load (Python), httpx (for web_to_md), Jina Reader API

## Testing
- **Coverage**: 0% (external dependencies)
- **Note**: Testing requires mocking subprocess calls

## Implementation Notes

### Absolute Path Enforcement
All filesystem tools raise `ValueError` if path starts with '.' to prevent ambiguity across different working directories. Instructed to use `pwd` to resolve current directory.

### Script Discovery
Searches for scripts in:
1. `Path(__file__).parents[4] / "core" / "scripts" / script_name`
2. `Path.cwd() / "core" / "scripts" / script_name`

### NPL Resource Loading
The `--skip` parameter is critical for preventing redundant loading of resources already injected into agent context.

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/08-script-wrappers.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/script-tools.yaml`
