# Review: Convert Web Pages to Markdown

- **Story**: `project-management/user-stories/US-096-convert-web-pages-to-markdown.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`web_to_md` is implemented at `src/npl_mcp/scripts/wrapper.py:195-217` as a thin wrapper over `npl_mcp.browser.to_markdown.to_markdown`, which routes URLs through `MarkdownConverter._convert_url_jina` (`src/npl_mcp/markdown/converter.py:123-145`) against `https://r.jina.ai/{url}` with optional `JINA_API_KEY` bearer auth, caches results (`MarkdownCache`), strips the Jina metadata header (`to_markdown.py:162-187`), and returns a dict with `content` and `content_length` (`to_markdown.py:69`). Errors from `raise_for_status()` propagate and are caught in the wrapper, returning `{"error": ...}` gracefully. Two deviations from spec: the `timeout` parameter is accepted but explicitly ignored (`wrapper.py:197`, noqa'd — the underlying converter uses its own 30s default), and the response carries no explicit `success` key (and uses `source` rather than `url`). Story's cited paths (`worktrees/main/mcp-server/unified.py:200-238`) are stale. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Fetch URL and convert via `web_to_md()` | Met | `src/npl_mcp/scripts/wrapper.py:195-217`; exported in `src/npl_mcp/scripts/__init__.py:6,8` |
| Uses Jina Reader API for HTML-to-markdown | Met | `src/npl_mcp/markdown/converter.py:123-145` (`https://r.jina.ai/{url}`); header stripping `src/npl_mcp/browser/to_markdown.py:162-187` |
| Optional API key for higher rate limits | Met | `JINA_API_KEY` env → `Authorization: Bearer` header, `src/npl_mcp/markdown/converter.py:130,137-138` |
| Returns formatted markdown with success status | Partially Met | Success dict has `content`, `source`, `content_length`, `source_type` (`to_markdown.py:45-84`) but no `success` boolean; errors return `{"error": ...}` (`wrapper.py:216-217`) — caller must infer success from key presence |
| Includes content length in metadata | Met | `result["content_length"] = len(processed)` `src/npl_mcp/browser/to_markdown.py:69` |
| Supports timeout parameter (default 30s) | Partially Met | `web_to_md(url, timeout)` accepts the param but ignores it (`wrapper.py:197`, "currently informational only"); the 30s default lives in the converter (`converter.py:49`) and is not controllable through `web_to_md` |
| Handles HTTP errors gracefully | Met | `response.raise_for_status()` `converter.py:142` → exception caught in wrapper → error dict `wrapper.py:214-217` |

## Gaps / Risks

- `web_to_md`'s timeout contract is misleading: documented as seconds, actually a no-op. Pass-through to `MarkdownConverter.convert(source, timeout=...)` would be a small fix.
- No `success` flag means programmatic callers (per US-097-style integrations) must sniff for an `error` key.
- Jina free-tier rate limiting is unhandled — no retry/backoff on 429.
- Tests exist for header stripping (`tests/test_to_markdown_strip.py`, 28 tests) and the converter (`tests/test_markdown_converter.py`) but not for the `web_to_md` wrapper itself.

## BDD Scenario

```gherkin
Feature: Convert web pages to markdown

  Scenario: Vibe coder ingests a documentation page
    When the agent calls web_to_md with url="https://docs.example.com/api-reference"
    Then the response includes "content" as markdown, "content_length", and "source"
    And the Jina "Title:/URL Source:/Markdown Content:" header has been stripped

  Scenario: Authenticated higher-rate-limit fetch
    Given JINA_API_KEY is set in the environment
    When web_to_md fetches a URL
    Then the request to r.jina.ai carries an Authorization Bearer header

  Scenario: Target page returns HTTP 404
    When web_to_md fetches a URL that returns 404
    Then raise_for_status raises and the response is {"error": "<message>"}
    # No exception escapes to the caller.

  Scenario: Caller requests a custom timeout
    When the agent calls web_to_md with timeout=10
    Then the fetch is bounded by 10 seconds
    # Today: NOT met — the timeout argument is ignored (wrapper.py:197).
```
