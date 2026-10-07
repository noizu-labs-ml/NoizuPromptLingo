# Review: Convert Documentation Sources to Markdown

- **Story**: `project-management/user-stories/US-206-convert-documentation-to-markdown.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`MarkdownConverter` (`src/npl_mcp/markdown/converter.py:39`) implements URL conversion via the Jina Reader API with SSE streaming (`converter.py:123-145`, `https://r.jina.ai/{url}`, optional `JINA_API_KEY`), source-type dispatch by URL prefix/extension (`converter.py:74-86`), and full PDF conversion (Jina base64 POST + pdfplumber fallback, `converter.py:226-320`) — beyond the story's "PDF stub" scope. DOCX and image conversion remain explicit stubs raising NotImplementedError (`converter.py:322-344`), matching the story's stub requirement. The YAML metadata header includes all six required fields (`converter.py:346-367`). Both surfaces exist: the `2md` CLI (`pyproject.toml:71`, `tools/convert_to_markdown.py`) and the MCP `ToMarkdown` tool (`src/npl_mcp/browser/to_markdown.py:16`, which orchestrates MarkdownConverter/MarkdownCache). The weak spot is error handling: `_convert_url` swallows all exceptions and returns `""` (`converter.py:108-121`), so failures still produce a `success: true` header with empty content; file-not-found surfaces as a raw unhandled FileNotFoundError at `converter.py:86`; timeouts are caught by the same blanket except.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: Convert URLs via Jina API (r.jina.ai) | Met | `converter.py:123-145` streams from `https://r.jina.ai/{url}` with auth/shadow-dom headers; optional html2text fallback (`converter.py:147-162`) |
| AC-2: YAML metadata header (success, source, source_type, cached, cache_file, content_length) | Met | `converter.py:346-367` emits all six fields, cached flag included |
| AC-3: Multiple source types with type detection (URL, file, PDF/DOCX/Image stubs) | Met | Dispatch at `converter.py:74-86`; PDF fully implemented (`converter.py:226-320`); DOCX/Image raise NotImplementedError stubs (`converter.py:322-344`) |
| AC-4: Error handling for file-not-found, HTTP errors, timeouts | Partially Met | Missing file → unhandled FileNotFoundError (`converter.py:86`; test asserts the raise, `tests/test_markdown_converter.py:482-483`); HTTP/timeout errors swallowed in `_convert_url` returning "" with `success: true` (`converter.py:112-121`) |
| AC-5: Works with CLI `2md` and MCP `to_markdown` | Met | `2md` entry point (`pyproject.toml:71`) building MarkdownConverter (`tools/convert_to_markdown.py:80-86`); MCP tool `src/npl_mcp/browser/to_markdown.py:92-111` |

## Gaps / Risks

- Silent-failure path: a Jina outage or timeout yields `success: true, content_length: 0` output rather than an error — callers cannot distinguish failure without inspecting content_length.
- `_convert_url_direct` fallback is disabled by default (`fallback_parser=False`), so without a fallback flag a Jina failure always returns empty.
- DOCX/image paths raise NotImplementedError after the source-type dispatch; a user converting a .docx gets a raw exception, not a friendly message (CLI may or may not catch it).
- Test suite is substantial (58 tests in tests/test_markdown_converter.py) including force_refresh and error classes, which supports the implemented criteria.

## BDD Scenario

```gherkin
Feature: Convert documentation sources to markdown
  As a content developer using 2md or the ToMarkdown MCP tool
  I want URLs and documents converted to markdown with metadata

  Scenario: Convert a URL
    When I run "2md https://example.com/docs"
    Then content is fetched via the Jina Reader SSE stream
    And output begins with a YAML header containing success, source, source_type, cached, cache_file, and content_length
    And the result is cached under .tmp/cache/markdown/

  Scenario: Convert a PDF
    When I run "2md report.pdf"
    Then pages are extracted (Jina when JINA_API_KEY is set, else pdfplumber locally)
    And text is returned with "## Page N" markers

  Scenario: URL conversion failure
    When the Jina request fails or times out for "2md https://broken.example.com"
    Then today no error is raised — output shows success: true with content_length: 0
    And the failure is only detectable via the empty content
```
