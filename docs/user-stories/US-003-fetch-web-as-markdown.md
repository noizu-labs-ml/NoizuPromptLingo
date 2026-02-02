# User Story: Fetch Web Content as Markdown

**ID**: US-003
**Persona**: P-003 (Vibe Coder)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **fetch web page content and convert it to markdown**,
So that **I can quickly capture documentation, articles, or reference material for my work**.

## Acceptance Criteria

### MCP Tool (`web_to_md`)
- [ ] Can fetch any public URL and convert to clean markdown
- [ ] Preserves headings, lists, code blocks, and links
- [ ] Strips navigation, ads, and boilerplate content
- [ ] Handles timeout gracefully with configurable duration (default: 30s)
- [ ] Returns error message for inaccessible URLs
- [ ] Content is suitable for immediate use in chat or artifacts

### Claude Code Integration
- [ ] AI agents can use WebFetch to retrieve and analyze web content
- [ ] Handles conversion of HTML to markdown automatically
- [ ] Returns processed content based on provided prompt
- [ ] Fails gracefully for authenticated URLs with clear error messages

## Notes

### MCP Implementation
- Uses Jina Reader service (`https://r.jina.ai/<url>`) for HTML-to-markdown conversion
- MCP tool: `web_to_md` (Script Tools category)
- Parameters: `url` (required), `timeout` (optional, default 30s)
- Returns: `{ "status": "ok", "result": "<markdown content>" }`

### Claude Code Integration
- Uses WebFetch tool with `url` and `prompt` parameters
- WebFetch converts HTML to markdown, then processes with AI model
- **Important**: Only works with public, unauthenticated URLs
- For authenticated URLs (Google Docs, private GitHub), use alternative tools (gh CLI, etc.)

### Edge Cases
- Should handle common edge cases (paywalls, JavaScript-heavy sites)
- Timeout should default to 30 seconds but be configurable
- Sites blocking automated access may return limited content

## Dependencies

### MCP Tool
- Network access to target URL
- Jina Reader service availability (`https://r.jina.ai`)
- Python `requests` library for HTTP calls

### Claude Code
- WebFetch tool availability (built-in to Claude Code)
- Public URL (no authentication required)

## Open Questions

- Should there be a maximum content length returned by `web_to_md`?
- How to handle sites that block automated access (return partial content or error)?
- Should WebFetch be preferred over `web_to_md` for AI agent workflows?
- Should we cache results to avoid repeated fetches of the same URL?

## Related Tools & Commands

### MCP Tools
- `web_to_md` (Script Tools) - Primary implementation for NPL users

### Claude Code Tools
- `WebFetch` (Web Operations) - AI agent usage for fetching and analyzing public web content

### See Also
- [MCP Reference: Script Tools](/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/reference/mcp.md#script-tools)
- [Claude Tools: Web Operations](/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools/web-ops.md)
