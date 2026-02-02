# User Story: Extract Web Content Programmatically

**ID**: US-091
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Documented
**Created**: 2026-02-02

## Story

As an **AI agent**,
I want to **extract text, HTML, and structured data from web pages using CSS selectors**,
So that **I can scrape and analyze web content for automation workflows**.

## Acceptance Criteria

- [ ] Can extract text content from elements using `browser_get_text(selector)`
- [ ] Can retrieve page or element HTML via `browser_get_html()`
- [ ] Can query multiple elements returning structured data via `browser_query_elements()`
- [ ] Can execute custom JavaScript via `browser_evaluate()`
- [ ] Supports timeout parameters for element wait
- [ ] Returns structured results with visibility, bounding box, and attributes
- [ ] Works across persistent browser sessions

## Implementation Status

✅ **Implemented in mcp-server worktree**

### MCP Tools

- `browser_get_text(selector, session_id, timeout)` - Extract element text content
- `browser_get_html(session_id, selector, outer)` - Get page/element HTML (innerHTML/outerHTML)
- `browser_query_elements(selector, session_id, limit)` - Query multiple elements with metadata
- `browser_evaluate(expression, session_id)` - Execute JavaScript in page context

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 830-913)

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/07-browser-automation.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/browser-tools.yaml`

## Example Usage

```python
# Extract product title
title = await browser_get_text("h1.product-title", session_id="scraper")

# Get article HTML
html = await browser_get_html(session_id="scraper", selector="article", outer=False)

# Query all product cards with metadata
products = await browser_query_elements(".product-card", session_id="scraper", limit=20)
# Returns: [{tag, text, visible, bounding_box, attributes}, ...]

# Execute custom JavaScript
link_count = await browser_evaluate("document.querySelectorAll('a').length", session_id="scraper")
```

## Related Stories

- US-012: Capture Screenshot of Current Work
- US-021: Navigate and Interact with Web Pages
- US-024: Manage Browser Session State
