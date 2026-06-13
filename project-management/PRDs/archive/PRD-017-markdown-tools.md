# PRD: Markdown Conversion and Viewing Tools

**Version**: 1.0
**Status**: Implemented (Phase 1)
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

---

## Overview

This PRD defines three CLI tools and two MCP tools for markdown conversion and viewing:

**CLI Tools**:
1. **2md** - Convert web pages, documents, and images to markdown with hybrid caching
2. **md-view** - Pure pipe filter for markdown (stdin → stdout) with optional filtering and collapsing
3. **view-md** - Combined converter + filter tool (source → markdown → filtered output)

**MCP Tools**:
1. **to_markdown** - MCP version of `2md` (conversion only)
2. **view_markdown** - MCP version of `view-md` (combined convert + filter)

These tools address the need for developers and AI agents to efficiently convert documentation sources to markdown, navigate large markdown documents through filtering and collapsing, and combine operations in flexible pipelines.

### Design Philosophy

- **Hybrid caching**: Local files cache next to source (`.pdf.md`), URLs cache in `.tmp/cache/markdown/`
- **Progressive enhancement**: Phase 1 delivers core functionality; stubs enable future CSS/XPath support
- **Zero new dependencies**: Phase 1 uses only existing project dependencies (httpx for Jina API)
- **Dual interface**: Both CLI tools and MCP tools share the same underlying modules

---

## User Stories

User stories for this PRD are defined in separate files for clarity and reusability:

### Content Developer Converting Documentation

| ID | Title | File | Persona |
|---|---|---|---|
| US-206 | Convert Documentation Sources to Markdown | `project-management/user-stories/US-206-convert-documentation-to-markdown.md` | P-003 (Vibe Coder) |
| US-207 | Cache Converted Files with Hybrid Strategy | `project-management/user-stories/US-207-cache-converted-files.md` | P-003 (Vibe Coder) |
| US-208 | Configure Cache Expiry for URL Caches | `project-management/user-stories/US-208-configure-cache-expiry.md` | P-003 (Vibe Coder) |

### AI Agent Filtering Documentation

| ID | Title | File | Persona |
|---|---|---|---|
| US-209 | Filter Markdown by Heading Path | `project-management/user-stories/US-209-filter-markdown-by-heading-path.md` | P-001 (AI Agent) |
| US-210 | Filter Markdown by Heading Level Selectors | `project-management/user-stories/US-210-filter-by-heading-level.md` | P-001 (AI Agent) |
| US-211 | MCP Tools for Markdown Conversion and Viewing | `project-management/user-stories/US-211-mcp-markdown-conversion-tools.md` | P-001 (AI Agent) |

### Technical Writer Managing Deep Documents

| ID | Title | File | Persona |
|---|---|---|---|
| US-212 | Collapse Markdown Sections Below Depth Level | `project-management/user-stories/US-212-collapse-sections-by-depth.md` | P-003 (Vibe Coder) |
| US-213 | Combine Filtering and Collapsing in Pipeline | `project-management/user-stories/US-213-combine-filter-and-collapse.md` | P-003 (Vibe Coder) |
| US-214 | Markdown Output Format Options | `project-management/user-stories/US-214-markdown-output-format-options.md` | P-003 (Vibe Coder) |

**To load a user story**: Reference the story file or use the MCP tool `get-story {story-id}`

---

## Functional Requirements

### FR-1: Hybrid Cache Manager

**Description**: Implement a caching strategy that stores converted markdown based on source type.

**Module**: `src/npl_mcp/markdown/cache.py`

**Interface**:
```python
class MarkdownCache:
    def __init__(self, cache_dir: Optional[Path] = None):
        """Initialize cache with optional custom directory for URL caches."""

    def get_cache_path(self, source: str) -> Path:
        """Get cache path based on source type."""

    async def get_cached(self, source: str, max_age: int = 3600) -> Optional[str]:
        """Retrieve cached content if valid."""

    async def save_cache(self, source: str, content: str) -> None:
        """Save content to cache."""
```

**Behavior**:

| Source Type | Cache Location | Expiry Policy |
|-------------|----------------|---------------|
| Local file (`/path/to/doc.pdf`) | `/path/to/doc.pdf.md` | Never expires |
| URL (`https://...`) | `.tmp/cache/markdown/{domain}.{path}.{hash}.md` | Configurable (default: 3600s) |

**Cache Path Generation for URLs**:
- Domain: Extract netloc, replace `:` with `_` for port handling
- Path: Extract stem of URL path, default to "index" for root
- Hash: MD5 of full URL, truncated to 8 characters
- Format: `{domain}.{path}.{hash}.md`

**Edge Cases**:
- Missing cache file: Return `None`
- Expired URL cache: Return `None`, trigger re-fetch
- Local file cache: Never check expiry (source file change triggers re-conversion)

### FR-2: Markdown Converter

**Description**: Convert various sources to markdown with automatic caching and YAML metadata headers.

**Module**: `src/npl_mcp/markdown/converter.py`

**Interface**:
```python
class MarkdownConverter:
    def __init__(self, cache: Optional[MarkdownCache] = None):
        """Initialize converter with optional cache."""

    async def convert(
        self,
        source: str,
        force_refresh: bool = False,
        timeout: int = 30
    ) -> str:
        """Convert source to markdown with caching."""
```

**Source Type Detection**:

| Pattern | Type | Handler |
|---------|------|---------|
| `http://` or `https://` | URL | Jina API via `r.jina.ai` |
| `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg` | Image | Phase 3 (stub) |
| `.pdf` | PDF | Phase 2 (stub) |
| `.docx`, `.doc` | Word | Phase 2 (stub) |
| Other | Text/Markdown | Direct read |

**Response Format**:
```yaml
success: true
source: {original_source}
source_type: url | file
cached: true | false
cache_file: {path_to_cache}
content_length: {length}
---
{markdown_content}
```

**Error Handling**:

| Error Condition | Error Type | Behavior |
|-----------------|------------|----------|
| File not found | `FileNotFoundError` | Propagate with message |
| Jina API failure | `httpx.HTTPError` | Propagate with status |
| PDF conversion (Phase 1) | `NotImplementedError` | Return stub message |
| DOCX conversion (Phase 1) | `NotImplementedError` | Return stub message |
| Image conversion (Phase 1) | `NotImplementedError` | Return stub message |

### FR-3: Heading Filter

**Description**: Filter markdown content by heading paths and level selectors.

**Module**: `src/npl_mcp/markdown/filters/heading.py`

**Interface**:
```python
class HeadingFilter:
    def filter(self, content: str, selector: str) -> str:
        """Apply heading selector to markdown content."""
```

**Selector Syntax**:

| Pattern | Description | Example |
|---------|-------------|---------|
| `heading-name` | Match by text (case-insensitive) | `"API Reference"` |
| `parent > child` | Nested path navigation | `"Overview > Installation"` |
| `parent > *` | All children of parent | `"API > *"` |
| `h1` - `h6` | Match by heading level | `"h2"` |

**Parsing Algorithm**:
1. Parse markdown into hierarchical section tree
2. Each section tracks: level, text, content lines, children
3. Navigate selector path through tree
4. Return matched section with full content

**Error Cases**:
- No sections found: Return `"# Error: No sections found in content"`
- Section not found: Return `"# Error: Section not found: {name}"`

### FR-4: Filter Type Detection

**Description**: Auto-detect and route to appropriate filter implementation.

**Module**: `src/npl_mcp/markdown/filters/__init__.py`

**Interface**:
```python
class FilterType(Enum):
    HEADING = "heading"
    CSS = "css"
    XPATH = "xpath"

def detect_filter_type(selector: str) -> FilterType
def apply_filter(content: str, selector: str) -> str
```

**Detection Rules**:

| Prefix/Pattern | Detected Type |
|----------------|---------------|
| `xpath:` | XPATH |
| `css:` | CSS |
| Contains `>`, `:`, `[`, `]` | HEADING |
| Default | HEADING |

### FR-5: CSS Filter (Stub)

**Description**: Placeholder for Phase 2 CSS selector filtering.

**Module**: `src/npl_mcp/markdown/filters/css.py`

**Behavior**: Raises `NotImplementedError` with message explaining Phase 2 implementation plan.

**Future Design**: Convert markdown to HTML, apply CSS selector, convert back to markdown.

### FR-6: XPath Filter (Stub)

**Description**: Placeholder for Phase 2 XPath filtering.

**Module**: `src/npl_mcp/markdown/filters/xpath.py`

**Behavior**: Raises `NotImplementedError` with message explaining Phase 2 implementation plan.

**Future Design**: Convert markdown to HTML, apply XPath expression, convert back to markdown.

### FR-7: Markdown Viewer

**Description**: View markdown with collapsible sections and optional filtering.

**Module**: `src/npl_mcp/markdown/viewer.py`

**Interface**:
```python
class MarkdownViewer:
    def view(
        self,
        content: str,
        filter: Optional[str] = None,
        collapsed_depth: Optional[int] = None,
        filtered_only: bool = False
    ) -> str:
        """View markdown with optional filtering and collapsing."""
```

**Behavior Pipeline**:
1. Apply filter if specified (via `apply_filter()`)
2. If `filtered_only=True`, return filtered content directly
3. If `collapsed_depth` specified, collapse sections below that depth
4. Return processed markdown

**Collapse Algorithm**:
- Parse lines, detect headings by `^#{1,6}\s+` pattern
- Track heading level and compare to depth threshold
- Replace collapsed content with `### [Collapsed]` marker
- Emit single marker for consecutive collapsed sections

**Valid Depth Values**: 1-6 (returns original if out of range)

### FR-8: CLI Tool - 2md

**Description**: Command-line interface for markdown conversion.

**Module**: `tools/2md.py`

**Console Script**: `2md` (via pyproject.toml)

**Usage**:
```bash
2md <source> [output] [options]
```

**Arguments**:

| Argument | Required | Description |
|----------|----------|-------------|
| `source` | Yes | URL, file path, or image to convert |
| `output` | No | Output file (default: stdout) |

**Options**:

| Option | Default | Description |
|--------|---------|-------------|
| `--format` | `rich` | Output format: `rich`, `plain`, `json` |
| `--no-cache` | False | Force fresh conversion (skip cache) |
| `--cache-dir` | `.tmp/cache/markdown/` | Custom cache directory |
| `--timeout` | 30 | Request timeout for URLs (seconds) |
| `--vision-prompt` | None | Custom prompt for image analysis (Phase 3) |
| `-q, --quiet` | False | Suppress non-content output |

**Output Formats**:

| Format | Description |
|--------|-------------|
| `rich` | Full response with YAML metadata header |
| `plain` | Content only (metadata stripped) |
| `json` | Structured JSON with metadata and content |

**Examples**:
```bash
# Convert URL to markdown
2md https://example.com/docs

# Convert with specific output file
2md https://api.docs.com/ref output.md

# Force refresh (skip cache)
2md https://example.com/docs --no-cache

# Plain format (no metadata)
2md page.html --format plain

# JSON format for programmatic use
2md https://example.com/docs --format json
```

### FR-9: CLI Tool - md-view

**Description**: Pure pipe filter for markdown (stdin → stdout) with optional filtering and collapsing.

**Module**: `tools/md_view.py`

**Console Script**: `md-view` (via pyproject.toml)

**Usage**:
```bash
md-view [options]
```

**Arguments**: None (reads from stdin only)

**Options**:

| Option | Description |
|--------|-------------|
| `--filter` | Filter selector (heading path, level, CSS, XPath) |
| `--bare` | Show ONLY filtered content (no collapsed headings) |
| `--depth` | Collapse headings below this depth (1-6) |
| `--rich` | Format markdown output with Rich (terminal styling) |

**Examples**:
```bash
# Filter by heading level from stdin
cat document.md | md-view --filter "h2"

# Filter by heading path from pipe
2md https://example.com | md-view --filter "API"

# Collapse deep sections
md-view --depth 2 < doc.md

# Filter with bare output (no collapse markers)
md-view --bare --filter "Features" < doc.md

# Rich formatting
cat doc.md | md-view --rich --filter "Installation"

# Combined filter and collapse
md-view --filter "API" --depth 2 < doc.md
```

### FR-10: CLI Tool - view-md

**Description**: Combined tool for converting a source and viewing with optional filtering/collapsing.

**Module**: `tools/view_md.py`

**Console Script**: `view-md` (via pyproject.toml)

**Usage**:
```bash
view-md <source> [output] [options]
```

**Arguments**:

| Argument | Required | Description |
|----------|----------|-------------|
| `source` | Yes | URL, file path, or image to convert and view |
| `output` | No | Output file (default: stdout) |

**Options**:

| Option | Default | Description |
|--------|---------|-------------|
| `--filter` | None | Filter selector (heading path, level, CSS, XPath) |
| `--bare` | False | Show ONLY filtered content (no collapsed headings) |
| `--depth` | None | Collapse headings below this depth (1-6) |
| `--rich` | False | Format markdown output with Rich (stdout only) |
| `--no-cache` | False | Force fresh conversion (skip cache) |
| `--cache-dir` | `.tmp/cache/markdown/` | Custom cache directory |
| `--timeout` | 30 | Request timeout for URLs (seconds) |
| `-q, --quiet` | False | Suppress non-content output |

**Examples**:
```bash
# Convert URL and view
view-md https://example.com/docs

# Convert and filter
view-md https://api.docs/ref --filter "Authentication"

# Convert, filter, and save
view-md report.pdf --filter "Results" --bare > results.md

# Convert with collapsing
view-md page.html --depth 2

# Convert and rich format display
view-md https://docs.com --rich --filter "API"

# Force refresh and collapse
view-md https://example.com/docs --no-cache --depth 2
```

### FR-11: MCP Tool - to_markdown

**Description**: MCP tool for markdown conversion via FastMCP server (maps to `2md` CLI).

**Tool Name**: `to_markdown`

**Interface**:
```python
@mcp.tool()
async def to_markdown(
    source: str,
    no_cache: bool = False,
    timeout: int = 30
) -> str:
    """Convert URL, file, or image to markdown with caching."""
```

**Returns**: Formatted markdown with YAML metadata header.

**Examples**:
```python
# Convert URL
result = await to_markdown("https://docs.example.com/api")

# Force fresh conversion
result = await to_markdown("report.pdf", no_cache=True)

# With custom timeout
result = await to_markdown("https://slow-site.com", timeout=60)
```

### FR-12: MCP Tool - view_markdown

**Description**: MCP tool for combined markdown conversion + viewing via FastMCP server (maps to `view-md` CLI).

**Tool Name**: `view_markdown`

**Interface**:
```python
@mcp.tool()
async def view_markdown(
    source: str,
    filter: Optional[str] = None,
    bare: bool = False,
    depth: Optional[int] = None,
    no_cache: bool = False,
    timeout: int = 30
) -> str:
    """Convert source to markdown, then filter and view with optional collapsing."""
```

**Returns**: Processed markdown based on filter/collapse options.

**Examples**:
```python
# Convert and view specific section
result = await view_markdown("https://docs.python.org", filter="Installation")

# Convert with collapsing
result = await view_markdown("report.pdf", depth=2)

# Show only filtered section
result = await view_markdown("doc.md", filter="API", bare=True)

# Force refresh with depth
result = await view_markdown("https://site.com/page", depth=2, no_cache=True)
```

---

## Non-Functional Requirements

| ID | Requirement | Metric |
|----|-------------|--------|
| NFR-1 | URL conversion must complete within timeout | Default 30s, configurable |
| NFR-2 | Cache lookup must be fast | < 10ms for local cache check |
| NFR-3 | Filter operations must handle large documents | Process 100K+ character docs |
| NFR-4 | No new PyPI dependencies for Phase 1 | Uses existing httpx |
| NFR-5 | Test coverage for core modules | 45+ tests passing |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| File not found | `FileNotFoundError` | "Error: File not found: {path}" |
| URL timeout | `httpx.TimeoutException` | "Error: Request timed out" |
| URL HTTP error | `httpx.HTTPStatusError` | "Error: HTTP {status} - {message}" |
| Invalid heading selector | N/A | "# Error: Section not found: {name}" |
| PDF conversion (Phase 1) | `NotImplementedError` | "PDF conversion coming soon - will use Jina Document API" |
| DOCX conversion (Phase 1) | `NotImplementedError` | "DOCX conversion coming soon - will use Jina Document API" |
| Image conversion (Phase 1) | `NotImplementedError` | "Image conversion coming soon - will use Claude vision API" |
| CSS filter (Phase 1) | `NotImplementedError` | "CSS filtering coming in Phase 2..." |
| XPath filter (Phase 1) | `NotImplementedError` | "XPath filtering coming in Phase 2..." |

---

## Acceptance Criteria

### CLI Tools

**2md Tool**:
- [x] AC-1: `2md` converts URLs to markdown via Jina API
- [x] AC-2: `2md` caches local files next to source with `.md` extension
- [x] AC-3: `2md` caches URLs in `.tmp/cache/markdown/` with hashed filenames
- [x] AC-4: `2md` respects `--no-cache` flag for forced refresh
- [x] AC-5: `2md` supports `--format rich|plain|json` output modes

**md-view Tool** (pure pipe filter):
- [x] AC-6: `md-view` filters by heading name (case-insensitive)
- [x] AC-7: `md-view` filters by heading level (`h1` - `h6`)
- [x] AC-8: `md-view` filters by nested path (`parent > child`)
- [x] AC-9: `md-view` collapses sections below specified depth
- [x] AC-10: `md-view` reads from stdin only
- [x] AC-11: `md-view` combines filtering and collapsing
- [x] AC-12: `md-view` supports `--rich` flag for Rich markdown formatting

**view-md Tool** (combined convert + filter):
- [x] AC-13: `view-md` converts URLs, files, and images to markdown
- [x] AC-14: `view-md` applies filtering and/or collapsing to output
- [x] AC-15: `view-md` supports `--bare` flag for filtered-only output
- [x] AC-16: `view-md` supports `--depth` flag for controlled collapsing
- [x] AC-17: `view-md` supports `--rich` flag for Rich markdown formatting
- [x] AC-18: `view-md` respects caching options (`--no-cache`, `--cache-dir`)

### MCP Tools

- [ ] AC-19: `to_markdown` MCP tool is registered in FastMCP server
- [ ] AC-20: `view_markdown` MCP tool is registered in FastMCP server
- [ ] AC-21: MCP tools return structured responses with metadata
- [ ] AC-22: `view_markdown` combines conversion and filtering in single call

### Cache Behavior

- [x] AC-23: URL caches expire after `max_age` seconds (default 3600)
- [x] AC-24: Local file caches never expire
- [x] AC-25: Cache directories are created automatically
- [x] AC-26: Same URL always produces same cache path (deterministic)

### Filter Behavior

- [x] AC-27: Heading filter is case-insensitive
- [x] AC-28: Nested paths navigate hierarchy correctly
- [x] AC-29: Wildcard `*` returns all children at level
- [x] AC-30: Missing sections return error messages
- [x] AC-31: Filter type auto-detection works correctly

### Test Coverage

- [x] AC-32: Cache module has comprehensive test coverage
- [x] AC-33: Viewer module has comprehensive test coverage
- [x] AC-34: Heading filter has comprehensive test coverage
- [x] AC-35: All markdown tests pass

---

## Technical Requirements

### Phase 1 Dependencies (Current)

| Dependency | Version | Purpose |
|------------|---------|---------|
| `httpx` | >= 0.25.0 | Jina API requests for URL conversion |

**No new dependencies required for Phase 1.**

### Phase 2 Dependencies (Future)

| Dependency | Version | Purpose |
|------------|---------|---------|
| `beautifulsoup4` | TBD | HTML parsing for CSS/XPath filters |
| `lxml` | TBD | XPath support |
| `markdown` | TBD | Markdown to HTML conversion |

### Phase 3 Dependencies (Future)

| Dependency | Version | Purpose |
|------------|---------|---------|
| `anthropic` | TBD | Claude vision API for image analysis |

### API Integrations

| API | Purpose | Auth |
|-----|---------|------|
| Jina r.jina.ai | URL to markdown conversion | Optional `JINA_API_KEY` env var |

---

## Implementation Notes

### Reuses Existing Patterns

- **Jina API pattern**: Follows existing `web_to_md` implementation pattern
- **Cache directory**: Uses `.tmp/cache/` convention from project guidelines
- **Async patterns**: Consistent with other `async`/`await` code in codebase

### Module Structure

```
src/npl_mcp/markdown/
    __init__.py          # Exports: MarkdownCache, MarkdownConverter, MarkdownViewer
    cache.py             # MarkdownCache class (hybrid caching)
    converter.py         # MarkdownConverter class (conversion logic)
    viewer.py            # MarkdownViewer class (filtering + collapsing)
    filters/
        __init__.py      # FilterType enum, detect_filter_type(), apply_filter()
        heading.py       # HeadingFilter class (heading path navigation)
        css.py           # CSSFilter stub (Phase 2)
        xpath.py         # XPathFilter stub (Phase 2)

tools/
    2md.py               # CLI: Convert web page/doc/image to markdown
    md_view.py           # CLI: Pure pipe filter (stdin → stdout)
    view_md.py           # CLI: Combined convert + filter (source → filtered markdown)
```

### Console Scripts (pyproject.toml)

```toml
[project.scripts]
2md = "tools.2md:main"
md-view = "tools.md_view:main"
view-md = "tools.view_md:main"
```

### Progressive Feature Enhancement

Phase 1 establishes clean interfaces with stubs for future functionality:
- `_convert_pdf()` - Ready for Jina Document API
- `_convert_docx()` - Ready for Jina Document API
- `_convert_image()` - Ready for Claude Vision API
- `CSSFilter.filter()` - Ready for markdown-to-HTML-to-CSS pipeline
- `XPathFilter.filter()` - Ready for markdown-to-HTML-to-XPath pipeline

---

## Out of Scope

- Real-time collaborative markdown editing
- Markdown syntax validation/linting
- Markdown rendering to HTML/PDF output
- Version control for cached files
- Distributed caching (Redis, etc.)
- Authentication for cached content
- Rate limiting for Jina API calls

---

## Dependencies

### Internal Dependencies

- `httpx` (already in project dependencies)

### External Services

- Jina r.jina.ai service (optional API key for higher rate limits)

---

## Open Questions

- [x] Q1: Should URL cache expiry be configurable per-request? **Answer**: Yes, via `max_age` parameter
- [x] Q2: Should local file caches check source modification time? **Answer**: Not in Phase 1; cache persists until source is re-converted
- [ ] Q3: Should MCP tools support streaming for large documents?
- [ ] Q4: Should CSS/XPath filters preserve original markdown formatting?

---

## Test Summary

### Test Files

| File | Tests | Coverage |
|------|-------|----------|
| `tests/test_markdown_cache.py` | 12 | Cache path generation, storage, expiry |
| `tests/test_markdown_viewer.py` | 18 | Basic view, collapse, combined, edge cases |
| `tests/test_heading_filter.py` | 15 | Basic filter, nested paths, edge cases |

### Running Tests

```bash
# Run all markdown-related tests
uv run -m pytest tests/test_markdown_cache.py tests/test_markdown_viewer.py tests/test_heading_filter.py -v

# Run with coverage
mise run test-coverage
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-02 | npl-prd-editor | Initial PRD for Phase 1 implementation |
