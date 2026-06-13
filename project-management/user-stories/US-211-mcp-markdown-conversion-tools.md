# US-211: MCP Tools for Markdown Conversion and Viewing

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-211 |
| **Title** | MCP Tools for Markdown Conversion and Viewing |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-001 (AI Agent) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As an AI agent, I want MCP tool access to markdown conversion so I can process documentation programmatically.

This enables agents to access markdown conversion capabilities through the FastMCP server: the `to_markdown` tool provides pure conversion, while `view_markdown` combines conversion with filtering and collapsing in a single call.

---

## Acceptance Criteria

- [ ] **AC-1**: `to_markdown` MCP tool is registered in FastMCP server
- [ ] **AC-2**: `to_markdown` converts URLs, files, and images to markdown
- [ ] **AC-3**: `to_markdown` returns markdown with YAML metadata header
- [ ] **AC-4**: `to_markdown` supports `no_cache` parameter for forced refresh
- [ ] **AC-5**: `to_markdown` supports `timeout` parameter for URL requests
- [ ] **AC-6**: `view_markdown` MCP tool is registered in FastMCP server
- [ ] **AC-7**: `view_markdown` combines conversion and filtering in single call
- [ ] **AC-8**: `view_markdown` supports `filter`, `bare`, `depth`, `no_cache` parameters
- [ ] **AC-9**: Both tools return structured responses with metadata

---

## Technical Notes

- Registration: Add tools to `src/npl_mcp/unified.py`
- `to_markdown` interface: maps to MarkdownConverter.convert()
- `view_markdown` interface: maps to MarkdownViewer.view()
- Async implementation required for httpx operations
- Error handling: Return structured error responses

---

## Dependencies

- MarkdownConverter class (FR-2)
- MarkdownViewer class (FR-7)
- FastMCP server (unified.py)
- httpx for URL operations

---

## Test Coverage Requirements

- Unit tests for both MCP tools
- Integration tests with FastMCP server
- Tests for parameter handling
- Tests for error conditions
- Tests for caching behavior
- Target coverage: 80%+ for new code paths
