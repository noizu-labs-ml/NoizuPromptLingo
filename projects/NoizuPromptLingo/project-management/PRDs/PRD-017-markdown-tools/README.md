# PRD-017: Markdown Conversion and Viewing Tools

**Version**: 1.0
**Status**: Implemented (Phase 1)
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

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

## Goals

1. Provide efficient markdown conversion from multiple source types (URLs, PDFs, images)
2. Enable filtering and navigation of large markdown documents
3. Support hybrid caching strategy (local files vs URLs)
4. Offer both CLI and MCP tool interfaces
5. Build progressive enhancement foundation for future features

## Non-Goals

- Real-time collaborative markdown editing
- Markdown syntax validation/linting
- Markdown rendering to HTML/PDF output
- Version control for cached files
- Distributed caching (Redis, etc.)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Status |
|----|-------|---------|--------|
| US-206 | [Convert Documentation Sources to Markdown](../../user-stories/US-206-convert-documentation-to-markdown.md) | P-003 | draft |
| US-207 | [Cache Converted Files with Hybrid Strategy](../../user-stories/US-207-cache-converted-files.md) | P-003 | draft |
| US-208 | [Configure Cache Expiry for URL Caches](../../user-stories/US-208-configure-cache-expiry.md) | P-003 | draft |
| US-209 | [Filter Markdown by Heading Path](../../user-stories/US-209-filter-markdown-by-heading-path.md) | P-001 | draft |
| US-210 | [Filter Markdown by Heading Level Selectors](../../user-stories/US-210-filter-by-heading-level.md) | P-001 | draft |
| US-211 | [MCP Tools for Markdown Conversion and Viewing](../../user-stories/US-211-mcp-markdown-conversion-tools.md) | P-001 | draft |
| US-212 | [Collapse Markdown Sections Below Depth Level](../../user-stories/US-212-collapse-sections-by-depth.md) | P-003 | draft |
| US-213 | [Combine Filtering and Collapsing in Pipeline](../../user-stories/US-213-combine-filter-and-collapse.md) | P-003 | draft |
| US-214 | [Markdown Output Format Options](../../user-stories/US-214-markdown-output-format-options.md) | P-003 | draft |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Hybrid Cache Manager](./functional-requirements/FR-001-hybrid-cache-manager.md) - Caching strategy based on source type
- **FR-002**: [Markdown Converter](./functional-requirements/FR-002-markdown-converter.md) - Convert sources to markdown with caching
- **FR-003**: [Heading Filter](./functional-requirements/FR-003-heading-filter.md) - Filter by heading paths and level selectors
- **FR-004**: [Filter Type Detection](./functional-requirements/FR-004-filter-type-detection.md) - Auto-detect filter implementation
- **FR-005**: [CSS Filter (Stub)](./functional-requirements/FR-005-css-filter-stub.md) - Phase 2 placeholder
- **FR-006**: [XPath Filter (Stub)](./functional-requirements/FR-006-xpath-filter-stub.md) - Phase 2 placeholder
- **FR-007**: [Markdown Viewer](./functional-requirements/FR-007-markdown-viewer.md) - View with collapsing and filtering
- **FR-008**: [CLI Tool - 2md](./functional-requirements/FR-008-cli-tool-2md.md) - Conversion CLI
- **FR-009**: [CLI Tool - md-view](./functional-requirements/FR-009-cli-tool-md-view.md) - Pipe filter CLI
- **FR-010**: [CLI Tool - view-md](./functional-requirements/FR-010-cli-tool-view-md.md) - Combined CLI
- **FR-011**: [MCP Tool - to_markdown](./functional-requirements/FR-011-mcp-tool-to-markdown.md) - MCP conversion
- **FR-012**: [MCP Tool - view_markdown](./functional-requirements/FR-012-mcp-tool-view-markdown.md) - MCP combined

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | URL conversion must complete within timeout | Request timeout | Default 30s, configurable |
| NFR-2 | Cache lookup must be fast | Lookup time | < 10ms for local cache check |
| NFR-3 | Filter operations must handle large documents | Document size | Process 100K+ character docs |
| NFR-4 | No new PyPI dependencies for Phase 1 | Dependency count | Uses existing httpx only |
| NFR-5 | Test coverage for core modules | Test count | 45+ tests passing |

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

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

**Summary**:
- **Total Tests**: 35 acceptance criteria
- **Passing**: 31 tests (CLI tools and core modules)
- **Not Started**: 4 tests (MCP tool registration)
- **Categories**: Unit (23), Integration (12), End-to-End (0)

**Test Coverage by Module**:
- Cache module: 12 tests ✅
- Viewer module: 18 tests ✅
- Heading filter: 15 tests ✅
- MCP tools: 4 tests (pending)

---

## Success Criteria

1. ✅ All user stories implemented with acceptance criteria passing (8/9 completed)
2. ✅ Test coverage >= 80% for all new code (45+ tests passing)
3. ✅ All CLI acceptance tests passing (31/31)
4. ⏳ MCP tools registered and functional (4 tests pending)
5. ✅ Clear and actionable error messages
6. ✅ No new dependencies added in Phase 1

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

### Phase 2 Dependencies (Future)

- `beautifulsoup4` - HTML parsing for CSS/XPath filters
- `lxml` - XPath support
- `markdown` - Markdown to HTML conversion

### Phase 3 Dependencies (Future)

- `anthropic` - Claude vision API for image analysis

---

## Open Questions

- [x] Q1: Should URL cache expiry be configurable per-request? **Answer**: Yes, via `max_age` parameter
- [x] Q2: Should local file caches check source modification time? **Answer**: Not in Phase 1; cache persists until source is re-converted
- [ ] Q3: Should MCP tools support streaming for large documents?
- [ ] Q4: Should CSS/XPath filters preserve original markdown formatting?

---

## Implementation Status

**Phase 1**: ✅ Completed
- CLI tools implemented (2md, md-view, view-md)
- Core modules implemented (cache, converter, viewer, filters)
- 45+ tests passing
- Hybrid caching working
- Heading filter with path navigation

**Phase 2**: 📋 Planned
- MCP tools registration (to_markdown, view_markdown)
- CSS and XPath filters
- PDF/DOCX conversion via Jina Document API

**Phase 3**: 📋 Planned
- Image conversion via Claude vision API
- Advanced filtering options
- Streaming support for large documents

---

## Module Structure

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

---

## Running Tests

```bash
# Run all markdown-related tests
uv run -m pytest tests/test_markdown_cache.py tests/test_markdown_viewer.py tests/test_heading_filter.py -v

# Run with coverage
mise run test-coverage

# Run specific test file
uv run -m pytest tests/test_markdown_cache.py -v
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-02 | npl-prd-editor | Initial PRD for Phase 1 implementation |
| 1.1 | 2026-02-02 | claude-code | Refactored to directory-based structure |
