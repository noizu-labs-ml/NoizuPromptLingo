# Review: Configure Cache Expiry for URL Caches

- **Story**: `project-management/user-stories/US-208-configure-cache-expiry.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The expiry core is implemented and tested: `MarkdownCache.get_cached(source, max_age=3600)` compares cache mtime against `max_age` for URL sources only (`src/npl_mcp/markdown/cache.py:67-89`), returning None for expired entries so the converter re-fetches and overwrites (`src/npl_mcp/markdown/converter.py:68-71,89-90`); `force_refresh` and `no_cache` flags exist on `MarkdownConverter.convert` (`converter.py:48-50,68,89`) with tests (`tests/test_markdown_converter.py:421-465`), and the CLI wires `--no-cache` through (`tools/convert_to_markdown.py:51-56,86`). However, the story's configurability requirement stops at the cache API: no caller passes a custom `max_age` — `converter.convert` calls `get_cached(source)` with the default (`converter.py:69`), the CLI has no `--max-age` flag, and the MCP `ToMarkdown` tool exposes neither `no_cache`/`force_refresh` nor `max_age` (`src/npl_mcp/browser/to_markdown.py:16-25`). The <10ms expiry check is satisfied by design (a single `stat()`), but no perf test exists.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: Default URL cache expiry is 3600s | Met | `get_cached(source, max_age=3600)` default (`src/npl_mcp/markdown/cache.py:67`); tests `tests/test_markdown_cache.py:244-261` |
| AC-2: Expiry configurable via `max_age` parameter | Partially Met | `max_age` exists on the API (`cache.py:67-72`; test `test_custom_max_age_parameter` at `tests/test_markdown_cache.py:294`) but is not wired through converter (`converter.py:69` uses default), CLI, or MCP tool |
| AC-3: Expired caches re-fetched on next access | Met | `get_cached` returns None past max_age (`cache.py:84-87`) → converter fetches and `save_cache` overwrites (`converter.py:74-90`) |
| AC-4: `--no-cache` / `force_refresh` forces fresh conversion | Partially Met | Both flags implemented and tested (`converter.py:48-50,68`; `tests/test_markdown_converter.py:424-465`; CLI `--no-cache` at `tools/convert_to_markdown.py:51-56`) — but the MCP `ToMarkdown` tool exposes neither parameter (`src/npl_mcp/browser/to_markdown.py:16-25`) |
| AC-5: Expiry check < 10ms via file mtime | Partially Met | Single `stat()` + comparison (`cache.py:85`) trivially meets the budget, but no perf test or measurement exists |
| AC-6: Both CLI and MCP tools support expiry configuration | Not Met | CLI: `--no-cache` only, no max-age flag; MCP `ToMarkdown`: no `no_cache`, `force_refresh`, or `max_age` parameters at all |

## Gaps / Risks

- Per-request freshness control is effectively unavailable to end users: the story's headline use case ("override with max_age for special needs") has no surface — only the internal API accepts max_age.
- The MCP `ToMarkdown` tool always caches with the 3600s default and offers no bypass, so agents cannot force a fresh fetch.
- Expired cache files are overwritten on re-fetch rather than removed first (story Technical Notes say "Remove expired cache file, then fetch fresh"); if a re-fetch fails silently (see US-206 review), the stale file remains and keeps being served after expiry until an overwrite succeeds.
- Story's configuration precedence (CLI flag → parameter → env var → default) is not implemented; there is no env-var source for max_age.

## BDD Scenario

```gherkin
Feature: Configurable cache expiry for URL conversions
  As a content developer
  I want URL caches to expire on a configurable schedule

  Scenario: Default expiry
    Given a URL cached 2 hours ago
    When I convert the URL via "2md https://example.com/guide"
    Then the cache is treated as expired (default max_age 3600s)
    And fresh content is fetched and the cache file rewritten

  Scenario: Custom max_age (not yet exposed)
    When I want a 60-second cache
    Then there is no CLI flag or MCP parameter to set max_age
    And only the internal MarkdownCache.get_cached API accepts it

  Scenario: Force refresh from the CLI
    When I run "2md https://example.com/guide --no-cache"
    Then the cache is skipped for both read and write
    And a fresh conversion is returned

  Scenario: Force refresh from the MCP tool (not yet exposed)
    When an agent calls the ToMarkdown MCP tool
    Then no no_cache/force_refresh/max_age parameters exist
    And conversion always uses the 3600s cache policy
```
