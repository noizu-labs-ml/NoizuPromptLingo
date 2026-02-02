# US-208: Configure Cache Expiry for URL Caches

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-208 |
| **Title** | Configure Cache Expiry for URL Caches |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a content developer, I want URL caches to expire after a configurable time so I get fresh content when needed.

This enables control over cache freshness with per-request configuration: developers can use default expiry (3600s) for most cases, override with `max_age` parameter for special needs, or force refresh with `--no-cache` flag.

---

## Acceptance Criteria

- [ ] **AC-1**: Default URL cache expiry is 3600 seconds (1 hour)
- [ ] **AC-2**: Expiry time is configurable via `max_age` parameter (seconds)
- [ ] **AC-3**: Expired caches are re-fetched on next access
- [ ] **AC-4**: `--no-cache` / `force_refresh=True` forces fresh conversion (skip cache entirely)
- [ ] **AC-5**: Cache expiry check is fast (< 10ms) using file modification time
- [ ] **AC-6**: Both CLI tools and MCP tools support expiry configuration

---

## Technical Notes

- Expiry check: Compare file modification time to current time
- Expired cache detection: mtime + max_age < now()
- Re-fetch behavior: Remove expired cache file, then fetch fresh
- Configuration sources: CLI flag → parameter → environment variable → default
- Local file caches: Never expire (different from URL caches)

---

## Dependencies

- MarkdownCache.get_cached() with max_age parameter (FR-1)
- File system access for modification time
- httpx for fetch operations

---

## Test Coverage Requirements

- Unit tests for expiry calculation
- Tests for --no-cache flag
- Tests for configurable max_age parameter
- Tests for re-fetch behavior on expiry
- Tests for performance (cache lookup < 10ms)
- Edge cases: future mtimes, missing files, permission issues
- Target coverage: 80%+ for new code paths
