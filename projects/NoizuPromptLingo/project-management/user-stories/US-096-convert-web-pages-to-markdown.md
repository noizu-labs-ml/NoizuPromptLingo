# User Story: Convert Web Pages to Markdown

**ID**: US-096
**Persona**: P-003 (Vibe Coder)
**Priority**: Medium
**Status**: Documented
**Created**: 2026-02-02

## Story

As a **vibe coder**,
I want to **fetch web pages and convert them to markdown format**,
So that **I can quickly ingest documentation and web content into my coding context**.

## Acceptance Criteria

- [ ] Can fetch URL and convert to markdown via `web_to_md()`
- [ ] Uses Jina Reader API for HTML-to-markdown conversion
- [ ] Supports optional API key for higher rate limits
- [ ] Returns formatted markdown with success status
- [ ] Includes content length in response metadata
- [ ] Supports timeout parameter (default: 30 seconds)
- [ ] Handles HTTP errors gracefully

## Implementation Status

✅ **Implemented in mcp-server worktree**

### MCP Tools

- `web_to_md(url, timeout)` - Fetch URL and return markdown-formatted content

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 200-238)

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/08-script-wrappers.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/script-tools.yaml`

## Example Usage

```python
# Fetch documentation page
markdown = await web_to_md(
    url="https://docs.example.com/api-reference",
    timeout=30
)
# Returns formatted markdown with metadata
```

## Response Format

```json
{
  "success": true,
  "url": "https://docs.example.com/api-reference",
  "content_length": 12453,
  "content": "# API Reference\n\n## Authentication\n\n..."
}
```

## Environment Variables

- `JINA_API_KEY`: Optional Jina Reader API key for authenticated requests

## Dependencies

- **External**: Jina Reader API (https://r.jina.ai/)
- **Python**: httpx library

## Notes

- Uses Jina Reader free tier by default (rate limited)
- Set `JINA_API_KEY` environment variable for higher limits
- Markdown conversion quality depends on page structure
- Some dynamic content may not convert properly

## Related Stories

- US-003: Fetch Web Content as Markdown
- US-001: Load NPL Core Components
- US-002: Load Project-Specific Context
