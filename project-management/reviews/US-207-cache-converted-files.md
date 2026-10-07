# Review: Cache Converted Files with Hybrid Strategy

- **Story**: `project-management/user-stories/US-207-cache-converted-files.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`MarkdownCache` (`src/npl_mcp/markdown/cache.py:14`) implements the hybrid strategy exactly as specified: local files cache next to the source with an appended `.md` suffix (`cache.py:35-49`, `doc.pdf` → `doc.pdf.md`, with a guard against double-extending already-markdown files), and URLs cache under `.tmp/cache/markdown/` using the `{domain}.{path}.{hash}.md` format (`cache.py:51-65`) with netloc port normalization (`:` → `_`), path stem extraction defaulting to `index`, and an 8-character MD5 of the full URL. Local caches never expire (the age check is gated to http(s) sources, `cache.py:83-87`); URL caches expire at the 3600s default (`cache.py:67`). Directories are created on init and on save (`cache.py:19,99`). Determinism holds since the hash input is the full URL string. Behavior is well tested — 31 tests in `tests/test_markdown_cache.py` cover path generation, port/https/query variants, expiry boundaries, never-expiring local files, custom max_age, and directory creation.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: Local files cache next to source with `.md` extension | Met | `cache.py:35-49` (`with_suffix(suffix + ".md")`); tests `tests/test_markdown_cache.py:61-90` |
| AC-2: URL caches in `.tmp/cache/markdown/` as `{domain}.{path}.{hash}.md` | Met | `cache.py:51-65` (`{domain}.{path_part}.{url_hash}.md`); tests at `tests/test_markdown_cache.py:100-149` |
| AC-3: Local file caches never expire | Met | Age check only for http(s) sources (`cache.py:83-87`); test `test_local_file_cache_never_expires` (`tests/test_markdown_cache.py:278`) |
| AC-4: URL caches expire after 3600s default | Met | `get_cached(source, max_age=3600)` with `age > max_age` → None (`cache.py:67,84-87`); tests at `tests/test_markdown_cache.py:244-261` |
| AC-5: Cache directories created automatically | Met | `mkdir(parents=True, exist_ok=True)` on init (`cache.py:19`) and per-save (`cache.py:99`); tests `tests/test_markdown_cache.py:344-354` |
| AC-6: Same URL always yields same cache path (MD5 of full URL) | Met | `hashlib.md5(url.encode()).hexdigest()[:8]` over the full URL (`cache.py:63`); tests `test_url_hash_consistency` / `test_similar_urls_produce_different_paths` (`tests/test_markdown_cache.py:115-122`) |

## Gaps / Risks

- Local `.md` source handling has a quirk: only the `.html.md` double-extension case returns the path unchanged; a plain `notes.md` source becomes `notes.md.md` (`cache.py:40-49`) — intentional per comment but surprising.
- Cache validity is keyed solely on the URL string; upstream content changes within max_age are invisible (accepted per story's Phase 1 scope).
- Local caches never check source mtime (explicit story decision, Technical Notes) — stale local caches persist until manually removed.

## BDD Scenario

```gherkin
Feature: Hybrid caching of converted markdown
  As a content developer converting docs via 2md or ToMarkdown
  I want conversions cached so unchanged sources are not re-fetched

  Scenario: Convert a local PDF twice
    Given a file "report.pdf" in the working directory
    When I run "2md report.pdf" twice
    Then the first run writes "report.pdf.md" next to the source
    And the second run returns the cached content with cached: true

  Scenario: Convert a URL twice within an hour
    When I run "2md https://example.com/guide" twice
    Then the first run writes .tmp/cache/markdown/example.com.guide.<hash>.md
    And the second run serves from cache with cached: true
    And the same URL always maps to the same cache file

  Scenario: Local cache ignores expiry
    When a locally cached ".md" file is older than any max_age
    Then it is still served from cache because local caches never expire
```
