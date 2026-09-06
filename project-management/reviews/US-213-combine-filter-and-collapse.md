# Review: Combine Filtering and Collapsing in Pipeline

- **Story**: `project-management/user-stories/US-213-combine-filter-and-collapse.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The filter-then-collapse pipeline exists on the Python API and the `ToMarkdown` MCP tool. `MarkdownViewer.view` (`src/npl_mcp/markdown/viewer.py:47-70`) applies the filter first (via `HeadingFilter.filter_with_context`, viewer.py:60) and then renders with global `depth` collapse applied (viewer.py:65-70, 174-175) — matching the story's specified order. Each option also works alone (viewer.py:48-51 depth-only; viewer.py:54-56 bare-filter-only). `ToMarkdown` exposes both together (`filter` + `collapsed_depth`, `src/npl_mcp/browser/to_markdown.py:16-25, 61-68`) with tests covering the combination (`tests/test_viewer...` — `tests/test_markdown_viewer.py:364-421`; `tests/test_to_markdown.py:252-272`). Structure preservation is tested (viewer tests:574-624). The named `view_markdown` MCP tool does not exist, and the `md-view`/`view-md` CLI tools named in AC-1/AC-2 are absent from the repo. No performance tests exist for AC-7. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `md-view` tool supports `--filter` and `--depth` together | Not Met | No evidence found — no `md-view` binary, script, or console entry point in the repo |
| AC-2: `view-md` tool supports `--filter` and `--depth` together | Not Met | No evidence found |
| AC-3: `view_markdown` MCP tool supports both parameters simultaneously | Partially Met | No `view_markdown` tool; `ToMarkdown` supports `filter` + `collapsed_depth` simultaneously (`src/npl_mcp/browser/to_markdown.py:61-68`; `tests/test_to_markdown.py:252-272`) |
| AC-4: Pipeline order: filter first, then collapse on filtered result | Met | `src/npl_mcp/markdown/viewer.py:59-70` — `filter_with_context` marks matches, then `_render_with_context` applies `depth` (viewer.py:174-175); `tests/test_markdown_viewer.py:364-421` |
| AC-5: Filter and collapse work independently | Met | depth-only path viewer.py:48-51; bare-filter path viewer.py:54-56; tests/test_markdown_viewer.py:111-201, 208-358 |
| AC-6: Combined operation maintains correct markdown structure | Met | `tests/test_markdown_viewer.py:523-544, 574-624` (code blocks, inline formatting, links, lists, blockquotes preserved) |
| AC-7: Performance remains acceptable for large documents | Not Met | No performance tests or benchmarks found for filtering/collapsing (story's own test-requirements list them) |

## Gaps / Risks

- CLI tools (`md-view`, `view-md`) referenced across the PRD/story cluster do not exist; only the MCP tool and Python API are real. Multiple sibling stories (US-212 AC-7, US-214 AC-7) inherit this gap.
- `filter_inner_depth` (collapse within matched sections only, viewer.py:16) gives finer control than the story describes but is not reachable from the `ToMarkdown` tool.
- Note on semantics: in context mode the global `depth` is applied to the WHOLE document, not just the filtered result — collapse-on-filtered-result (AC-4's literal wording) is approximated by marking, not by extraction-then-collapse. Bare mode + depth ignores depth entirely (viewer.py:54-56; tests:445).

## BDD Scenario

```gherkin
Feature: Combine filtering and collapsing in one pipeline
  As a technical writer I see a filtered view with controlled depth.

  Scenario: Filtered view with depth control via MCP
    Given a large markdown document
    When the agent calls ToolCall(tool="ToMarkdown", arguments={"source": "doc.md", "filter": "API", "collapsed_depth": 2})
    Then matching sections and their ancestors are shown expanded
    And non-matched siblings and anything below depth 2 are collapsed with 📦 markers

  Scenario: Each option alone
    When ToMarkdown is called with only collapsed_depth (or only filter)
    Then collapse-only (or filter-only) output is returned

  Scenario: CLI combined flags
    When a user runs "md-view doc.md --filter API --depth 2"
    Then the command fails — no such CLI tool exists
```
