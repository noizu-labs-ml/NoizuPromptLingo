# US-207: Cache Converted Files with Hybrid Strategy

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-207 |
| **Title** | Cache Converted Files with Hybrid Strategy |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a content developer, I want converted files cached next to the source so I don't re-fetch unchanged content.

This enables efficient caching with different strategies for local files vs URLs: local files cache next to source (`.md` extension), while URL conversions cache in `.tmp/cache/markdown/` with deterministic naming.

---

## Acceptance Criteria

- [ ] **AC-1**: Local files cache next to source with `.md` extension (e.g., `/path/to/doc.pdf.md`)
- [ ] **AC-2**: URL caches store in `.tmp/cache/markdown/` with deterministic path format: `{domain}.{path}.{hash}.md`
- [ ] **AC-3**: Local file caches never expire (persistent until source is re-converted)
- [ ] **AC-4**: URL caches expire after configurable time (default: 3600 seconds)
- [ ] **AC-5**: Cache directories are created automatically if missing
- [ ] **AC-6**: Same URL always produces same cache path (MD5 hash of full URL)

---

## Technical Notes

- URL cache path format: `{domain}.{path}.{hash}.md` where hash is MD5 of full URL truncated to 8 chars
- Domain extraction: `netloc`, replace `:` with `_` for port handling
- Path extraction: URL path stem, default to "index" for root
- Local file cache: Never check modification time in Phase 1
- Expiry check: Done on retrieval, stale caches are re-fetched

---

## Dependencies

- MarkdownCache class (FR-1)
- Cache path utilities
- httpx for cache operations

---

## Test Coverage Requirements

- Unit tests for cache path generation
- Tests for cache expiry logic
- Tests for directory creation
- URL and local file cache behavior tests
- Edge cases: missing files, expired caches, permission issues
- Target coverage: 80%+ for new code paths
