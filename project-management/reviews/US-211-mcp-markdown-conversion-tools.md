# Review: MCP Tools for Markdown Conversion and Viewing

- **Story**: `project-management/user-stories/US-211-mcp-markdown-conversion-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`to_markdown` exists as an async MCP-callable tool at `src/npl_mcp/browser/to_markdown.py:16`, registered in the discoverable tool catalog as `ToMarkdown` (`src/npl_mcp/meta_tools/discoverable_tools.py:19-27`) and callable via `ToolCall` per the server's meta-discovery pattern (it is hidden from the visible MCP list, not a directly-registered FastMCP tool; there is no `src/npl_mcp/unified.py`). It orchestrates `MarkdownConverter` (URL/PDF/HTML with cache, timeout, `no_cache` at `src/npl_mcp/markdown/converter.py:49-89`), `MarkdownViewer`, and image-description injection, returning a structured dict. However, the tool signature (to_markdown.py:16-25) does NOT expose `no_cache` or `timeout`, and it deliberately STRIPS the YAML metadata header produced by the converter (to_markdown.py:98, 135-159). The separate `view_markdown` tool does not exist anywhere; its combine-filter-and-collapse role is served by parameters on `to_markdown` itself. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `to_markdown` registered in FastMCP server | Met (via catalog) | `src/npl_mcp/meta_tools/discoverable_tools.py:19-27` registers `ToMarkdown` as discoverable/callable via `ToolCall`; not a directly visible FastMCP tool and no `unified.py` exists |
| AC-2: Converts URLs, files, and images to markdown | Partially Met | URLs and files (md/txt direct, HTML/PDF via converter) — `src/npl_mcp/browser/to_markdown.py:87-116`, converter.py:75-79; "images" only via LLM description injection (to_markdown.py:52-59), not image→markdown conversion |
| AC-3: Returns markdown with YAML metadata header | Not Met | Converter produces a YAML header (converter.py:347-355) but the tool strips it before returning (to_markdown.py:98, 135-159) |
| AC-4: `no_cache` parameter for forced refresh | Not Met (tool level) | `MarkdownConverter.convert` supports `no_cache` (converter.py:50, 67, 89) but `to_markdown`'s signature has no `no_cache` param (to_markdown.py:16-25) |
| AC-5: `timeout` parameter for URL requests | Not Met (tool level) | converter.py:49 supports timeout; `to_markdown` does not expose it (to_markdown.py:16-25) |
| AC-6: `view_markdown` registered in FastMCP server | Not Met | No evidence found — `view_markdown` appears nowhere in `src/` |
| AC-7: `view_markdown` combines conversion and filtering in one call | Partially Met | `to_markdown` itself combines conversion + filter + collapse (to_markdown.py:61-68; `tests/test_to_markdown.py:223-270`), but the named `view_markdown` tool is absent |
| AC-8: `view_markdown` supports `filter`, `bare`, `depth`, `no_cache` | Partially Met | Equivalent params exist on `to_markdown`: `filter`, `filtered_only` (bare), `collapsed_depth` (to_markdown.py:17-20); `no_cache` missing |
| AC-9: Structured responses with metadata | Met | Dict with `source`, `source_type`, `content_length`, `content`/`output_file` (to_markdown.py:45-84); `tests/test_to_markdown.py:368` (`test_tool_in_registry`) |

## Gaps / Risks

- Story's technical notes point to `src/npl_mcp/unified.py`, which does not exist — registration architecture diverged to the discoverable-catalog pattern; story should be updated.
- `no_cache`/`timeout` are implemented one layer down (converter) but unreachable through the MCP surface — cache-staleness bugs cannot be worked around by agents.
- AC-3 as written is now contradicted by design (header stripping was added intentionally, per `_strip_metadata_header`); the story and implementation disagree on intent.
- The split `to_markdown`/`view_markdown` from the PRD collapsed into a single tool; either the story or the PRD needs reconciliation.

## BDD Scenario

```gherkin
Feature: MCP tools for markdown conversion and viewing
  As an AI agent I process documentation through MCP tool calls.

  Scenario: Convert a URL with filtering and collapsing
    When the agent calls ToolCall(tool="ToMarkdown", arguments={"source": "https://example.com/docs", "filter": "API", "collapsed_depth": 2})
    Then a structured dict is returned with source metadata and processed content
    And the YAML metadata header is absent (stripped by design)

  Scenario: Convert a local file
    Given a local .md file
    When ToMarkdown is called with the file path
    Then the file content is returned directly without network access

  Scenario: Force a cache refresh
    When the agent tries to pass no_cache=true to ToMarkdown
    Then the parameter is rejected — no_cache exists only on MarkdownConverter.convert, not the MCP tool
```
