# Review: Fetch Web Content as Markdown

- **Story**: `project-management/user-stories/US-003-fetch-web-as-markdown.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The `web_to_md` MCP tool is implemented and registered (`src/npl_mcp/scripts/wrapper.py:195-217`, catalogued in `src/npl_mcp/meta_tools/discoverable_tools.py:230`). It wraps `to_markdown` (`src/npl_mcp/browser/to_markdown.py:16-84`), which resolves URLs through `MarkdownConverter` (Jina Reader with optional html2text fallback, `src/npl_mcp/markdown/converter.py:94-153`), strips Jina/converted metadata headers, supports heading/CSS/XPath filtering and collapse via `MarkdownViewer`, caching via `MarkdownCache`, optional file output, and LLM image descriptions. Errors are caught and returned as `{"error": ...}` rather than raising. Tests exist (`tests/test_to_markdown.py`, `tests/test_to_markdown_strip.py`, `tests/test_scripts_module.py:34,99`). The main shortfall: the story's configurable `timeout` parameter is accepted but silently ignored — `web_to_md` never passes it to the converter (`wrapper.py:197` marked `noqa ARG001`), so callers cannot change the converter's default 30s. The "Claude Code Integration" criteria describe the harness's built-in WebFetch tool, not code in this repo, so they are out of scope for codebase verification.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Fetch any public URL and convert to clean markdown | Met | `src/npl_mcp/browser/to_markdown.py:93-98` → `converter.convert` (Jina) |
| Preserves headings, lists, code blocks, links | Met | Jina Reader markdown output passed through unmodified after header strip (`to_markdown.py:135-187`) |
| Strips navigation, ads, boilerplate | Met | Jina Reader extraction; repo-side content shaping via `MarkdownViewer` filter/collapse (`to_markdown.py:62-68`); html2text fallback is less aggressive — minor caveat |
| Handles timeout gracefully with configurable duration (default 30s) | Partially Met | converter default `timeout: int = 30` and httpx timeout wiring exist (`converter.py:49,140,150`), but `web_to_md`'s timeout arg is discarded (`wrapper.py:197`) — not configurable from the tool |
| Returns error message for inaccessible URLs | Met | `wrapper.py:216-217` catches all exceptions → `{"error": str(exc)}`; converter raises on HTTP failure (`raise_for_status`, `converter.py:142,153`) |
| Content suitable for immediate use in chat or artifacts | Met | clean markdown string returned in `result["content"]`, metadata stripped, filterable/length-reported (`to_markdown.py:69-82`) |
| (Claude Code) WebFetch retrieval/HTML-to-markdown/processing/graceful auth-URL failure | Not Met (out of scope) | no evidence found in this repo — WebFetch is a Claude Code built-in, not implemented here |

## Gaps / Risks

- Timeout parameter is dead API surface: accepting `timeout` and ignoring it misleads callers relying on it for slow sites.
- Jina Reader is a third-party dependency; `_convert_url_jina` failure path depends on `fallback_parser=True` being passed, and `web_to_md` never passes it — so the html2text fallback is unreachable through `web_to_md` (always Jina-only).
- No max content length; a huge page returns the entire body into the agent context (story open question, unresolved).
- Sites blocking Jina return limited content with no explicit signal to the caller.
- Story's "Related Tools" links point at a stale absolute path (`/pools/throughput/...`).

## BDD Scenario

```gherkin
Feature: Fetch web page as markdown
  Scenario: Vibe coder captures documentation
    When the agent calls web_to_md with url "https://docs.example.com/guide"
    Then the response contains "content" as markdown with headings, lists, code fences, and links intact
    And Jina metadata (Title:/URL Source:/Markdown Content:) has been stripped
  Scenario: Filtered extraction
    When web_to_md is called with filter "API Reference" and filtered_only true
    Then only the matched sections are returned with content_length reported
  Scenario: Inaccessible URL
    When web_to_md is called with an unreachable URL
    Then the call returns {"error": "<message>"} instead of raising
  Scenario: Timeout configuration
    When web_to_md is called with timeout 60 on a slow site
    Then today the value is ignored — the converter applies its internal 30s default
```
