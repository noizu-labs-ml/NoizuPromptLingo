# US-206: Convert Documentation Sources to Markdown

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-206 |
| **Title** | Convert Documentation Sources to Markdown |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a content developer, I want to convert web documentation to markdown so I can reference it locally.

This enables seamless conversion of various documentation sources (URLs, PDFs, Word docs, images) into markdown format for offline reference, local processing, and integration with documentation pipelines.

---

## Acceptance Criteria

- [ ] **AC-1**: Can convert URLs to markdown via Jina API (`r.jina.ai`)
- [ ] **AC-2**: Converted content includes YAML metadata header (success, source, source_type, cached, cache_file, content_length)
- [ ] **AC-3**: Supports multiple source types with proper type detection (URL, local file, PDF stub, DOCX stub, Image stub)
- [ ] **AC-4**: Error handling for file not found, HTTP errors, timeouts
- [ ] **AC-5**: Works with CLI tool `2md` and MCP tool `to_markdown`

---

## Technical Notes

- Use Jina API for URL conversion (no new dependencies - httpx already available)
- Type detection based on URL patterns and file extensions
- Phase 1: URLs only; Phase 2+: PDF, DOCX, Image support
- Response format includes YAML header followed by markdown content

---

## Dependencies

- httpx (already in project dependencies)
- Jina r.jina.ai API endpoint
- MarkdownCache for caching (FR-1)
- MarkdownConverter class (FR-2)

---

## Test Coverage Requirements

- Unit tests for source type detection
- Integration tests for Jina API conversion
- Cache behavior validation
- Error handling for all error conditions
- Target coverage: 80%+ for new code paths
