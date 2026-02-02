# Category: NPL Script Wrappers

**Category ID**: C-08
**Tool Count**: 5
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The NPL Script Wrappers category provides MCP tool access to existing NPL command-line scripts for codebase exploration, content aggregation, and NPL framework resource loading. These tools act as async wrappers around subprocess calls to battle-tested bash and Python scripts in `core/scripts/`, enabling Claude Code to leverage NPL's existing CLI tooling through the MCP protocol.

This category bridges the gap between the NPL command-line ecosystem and MCP-based AI agent workflows. Tools enforce absolute path requirements to prevent ambiguity in multi-context environments and respect `.gitignore` rules to avoid exposing unwanted files.

## Features Implemented

### Feature 1: File Content Aggregation

**Description**: Dump contents of multiple files with headers, respecting `.gitignore` rules and supporting glob patterns.

**MCP Tools**:
- `dump_files(path, glob_filter)` - Concatenate file contents with headers for easy context loading

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/scripts/wrapper.py`
- Script: `core/scripts/dump-files`
- MCP Tool: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 161-169)

**Test Coverage**: 0% (external dependency)

**Example Usage**:
```python
# Dump all markdown files in docs directory
content = await dump_files(
    path="/home/user/project/docs",
    glob_filter="*.md"
)
```

### Feature 2: Directory Tree Visualization

**Description**: Display hierarchical directory structure with optional depth analysis, respecting `.gitignore` rules.

**MCP Tools**:
- `git_tree(path)` - Show directory tree using `tree` command or bash fallback
- `git_tree_depth(path)` - List directories with nesting depth relative to target

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/scripts/wrapper.py`
- Scripts: `core/scripts/git-tree`, `core/scripts/git-tree-depth`
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 172-191)

**Test Coverage**: 0% (external dependencies)

**Example Usage**:
```python
# Show directory structure
tree = await git_tree(path="/home/user/project/src")

# Analyze nesting depth
depth = await git_tree_depth(path="/home/user/project/src")
```

### Feature 3: NPL Framework Resource Loading

**Description**: Load NPL components, metadata, personas, and style guides with hierarchical path resolution and dependency tracking.

**MCP Tools**:
- `npl_load(resource_type, items, skip)` - Load NPL resources with skip flags to prevent reloading

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/scripts/wrapper.py`
- Script: `core/scripts/npl-load` (Python)
- MCP Tool: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 194-197)

**Test Coverage**: 0% (external dependency)

**Example Usage**:
```python
# Load syntax and agent components
npl_syntax = await npl_load(
    resource_type="c",
    items="syntax,agent,formatting",
    skip="syntax"  # Already loaded
)

# Load persona metadata
persona = await npl_load(
    resource_type="m",
    items="persona.qa-engineer",
    skip=""
)
```

### Feature 4: Web Content to Markdown Conversion

**Description**: Fetch web pages and convert to markdown using Jina Reader API.

**MCP Tools**:
- `web_to_md(url, timeout)` - Fetch URL and return markdown-formatted content

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 200-238)

**Test Coverage**: 0% (external API dependency)

**Example Usage**:
```python
# Fetch documentation page
markdown = await web_to_md(
    url="https://example.com/docs",
    timeout=30
)
```

## MCP Tools Reference

### Tool Signatures

```python
async def dump_files(path: str, glob_filter: Optional[str] = None) -> str
async def git_tree(path: str = ".") -> str
async def git_tree_depth(path: str) -> str
async def npl_load(resource_type: str, items: str, skip: Optional[str] = None) -> str
async def web_to_md(url: str, timeout: int = 30) -> str
```

### Tool Descriptions

**dump_files**: Dump contents of files in a directory respecting .gitignore. IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'), not a relative path like '.' or './subdir'. Use pwd to get the current working directory if needed.

**git_tree**: Display directory tree respecting .gitignore. IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'), not a relative path like '.' or './subdir'. Use pwd to get the current working directory if needed.

**git_tree_depth**: List directories with nesting depth information. IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'), not a relative path like '.' or './subdir'. Use pwd to get the current working directory if needed.

**npl_load**: Load NPL components, metadata, or style guides. Supports resource types: 'c' (component), 'm' (meta), 's' (style). Items are comma-separated. Skip parameter prevents reloading already-loaded resources.

**web_to_md**: Fetch a web page and return its content as markdown using Jina Reader. Args: url (The URL of the web page to fetch), timeout (Request timeout in seconds, default 30). Returns: Formatted markdown string with success/failure status and content.

## Database Model

Not applicable - these tools do not interact with the database.

## User Stories Mapping

This category addresses:
- General codebase exploration workflows
- NPL framework integration
- Content aggregation for context loading

## Suggested PRD Mapping

These tools existed before the MCP server PRD and are not explicitly documented in `worktrees/main/mcp-server/docs/PRD.md`. They represent pre-existing NPL infrastructure integrated into the MCP server.

## API Documentation

### MCP Tools

#### dump_files

**Parameters**:
- `path` (str, required): Directory path to dump files from (must be absolute)
- `glob_filter` (str, optional): Glob pattern to filter files (e.g., "*.md")

**Returns**: Concatenated file contents with headers

**Raises**:
- `ValueError`: If path is relative (starts with '.')
- `FileNotFoundError`: If dump-files script not found
- `subprocess.CalledProcessError`: If script execution fails

#### git_tree

**Parameters**:
- `path` (str, default "."): Directory path to show tree for (must be absolute)

**Returns**: Directory tree output

**Raises**:
- `ValueError`: If path is relative (starts with '.')
- `FileNotFoundError`: If git-tree script not found
- `subprocess.CalledProcessError`: If script execution fails

#### git_tree_depth

**Parameters**:
- `path` (str, required): Directory path to analyze (must be absolute)

**Returns**: Directory listing with depth numbers

**Raises**:
- `ValueError`: If path is relative (starts with '.')
- `FileNotFoundError`: If git-tree-depth script not found
- `subprocess.CalledProcessError`: If script execution fails

#### npl_load

**Parameters**:
- `resource_type` (str, required): Type of resource - 'c' (component), 'm' (meta), or 's' (style)
- `items` (str, required): Comma-separated list of items to load (supports wildcards)
- `skip` (str, optional): Comma-separated list of patterns to skip

**Returns**: Loaded NPL content with tracking flags

**Raises**:
- `ValueError`: If invalid resource_type provided
- `FileNotFoundError`: If npl-load script not found
- `subprocess.CalledProcessError`: If script execution fails

**Note**: The tool returns content headers that set global flags (e.g., `npl.loaded=syntax,agent`). These flags must be passed back via `--skip` on subsequent calls to prevent reloading.

#### web_to_md

**Parameters**:
- `url` (str, required): The URL of the web page to fetch
- `timeout` (int, default 30): Request timeout in seconds

**Returns**: Formatted markdown string with:
- `success` status (true/false)
- `url` (original URL)
- `content_length` (character count)
- `content` (markdown-formatted page content)

**Environment Variables**:
- `JINA_API_KEY`: Optional Jina Reader API key for authenticated requests

**Raises**:
- `httpx.HTTPStatusError`: If HTTP request fails
- `httpx.TimeoutException`: If request times out

## Dependencies

### Internal Dependencies
- NPL core scripts (`core/scripts/`)
- Python subprocess module
- httpx library (for web_to_md)

### External Dependencies
- `dump-files` bash script
- `git-tree` bash script
- `git-tree-depth` bash script
- `npl-load` Python script
- Jina Reader API (https://r.jina.ai/)

## Testing

- **Test Files**: None (external dependencies)
- **Coverage**: 0%
- **Key Test Cases**: Not applicable - these tools wrap external scripts

Note: Testing would require mocking subprocess calls or providing test fixtures for the underlying scripts.

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (Script Tools section, lines 56-61)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (NPL Script Tools section, lines 209-230)
- **PRD**: Not documented (pre-existing tools)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (Script Wrappers section, lines 39-43)

## Implementation Notes

### Absolute Path Requirement

All file system tools (`dump_files`, `git_tree`, `git_tree_depth`) enforce absolute paths to prevent ambiguity when Claude Code operates in different working directories. The validation function raises `ValueError` if a path starts with '.', instructing callers to use `pwd` to resolve the current directory.

### Script Discovery

The `_find_script` helper searches for scripts in two locations:
1. Relative to mcp-server package: `Path(__file__).parents[4] / "core" / "scripts" / script_name`
2. Relative to current working directory: `Path.cwd() / "core" / "scripts" / script_name`

This allows the MCP server to find scripts whether run from the mcp-server subdirectory or the project root.

### NPL Resource Loading

The `npl-load` script uses hierarchical path resolution (project → user → system) to find NPL components. The `--skip` parameter is critical for preventing redundant loading of resources that have already been injected into the agent's context.

### Web to Markdown

The `web_to_md` tool uses Jina Reader (https://r.jina.ai/) to convert HTML to markdown. It supports optional API key authentication via `JINA_API_KEY` environment variable for higher rate limits and additional features.

### Error Handling

All tools use `subprocess.run(..., check=True)` to raise `CalledProcessError` on non-zero exit codes, allowing callers to handle script failures gracefully. The wrapper functions provide detailed error messages indicating which script failed and why.
