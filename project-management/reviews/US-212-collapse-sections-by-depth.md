# Review: Collapse Markdown Sections Below Depth Level

- **Story**: `project-management/user-stories/US-212-collapse-sections-by-depth.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Depth-based collapsing is implemented in `MarkdownViewer._collapse_sections` (`src/npl_mcp/markdown/viewer.py:72-127`) and in the context-aware renderer (`_render_with_context`, viewer.py:129-205). Content below the depth threshold is removed and headings at the collapse boundary are shown with a `📦` emoji marker (viewer.py:111, 190) — NOT the `### [Collapsed]` literal marker the story specifies; the test suite codifies the emoji deviation ("New behavior: heading text shown with 📦, not [Collapsed] marker", `tests/test_markdown_viewer.py:217-222`). Single-marker consolidation and depth 1-6 behavior are well tested (tests at viewer tests:211-278, 279-317). Invalid-depth behavior diverges from the story: depth 0/negative collapses the ENTIRE document rather than returning it unchanged, and depth ≥7 shows everything (tests:320-348). There is no CLI surface — only the `ToMarkdown` MCP tool (`collapsed_depth` param) and the Python API. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `--depth` flag accepts values 1-6 | Partially Met | `depth`/`collapsed_depth` params exist (`src/npl_mcp/markdown/viewer.py:15`, `src/npl_mcp/browser/to_markdown.py:19`) but no validation — out-of-range ints are silently reinterpreted; no CLI `--depth` flag exists |
| AC-2: Headings below depth replaced with `### [Collapsed]` marker | Partially Met | Boundary heading text is kept with a `📦` emoji appended (viewer.py:111, 190; tests/test_markdown_viewer.py:217-222) — content is collapsed but the specified marker format is not used |
| AC-3: Consecutive collapsed sections emit single marker | Met | `in_collapsed_section` state suppresses deeper markers (viewer.py:108-119); `tests/test_markdown_viewer.py:279-317` |
| AC-4: Collapsed content completely removed from output | Met | Content lines under collapsed sections skipped (viewer.py:120-125); tests/test_markdown_viewer.py:219-234 |
| AC-5: Original depth preserved for non-collapsed headings | Met | Headings at level ≤ depth emitted unchanged (viewer.py:102-105); tests/test_markdown_viewer.py:224-244 |
| AC-6: Invalid depth (0, 7+) returns original document | Partially Met | Depth 7+/100 shows all (tests:340-348) but depth 0/negative collapses ALL headings instead of returning the original (tests:320-334; no guard in viewer.py:94-119) |
| AC-7: Works with both CLI tools and MCP tools | Partially Met | MCP: `ToMarkdown(collapsed_depth=...)` (to_markdown.py:63-68; `tests/test_to_markdown.py:252-272`). CLI: no `2md`/`md-view`/`view-md` binaries or console scripts found anywhere in the repo |

## Gaps / Risks

- Marker format mismatch (`📦` vs `### [Collapsed]`) is now baked into tests — either the story or the implementation needs to be declared canonical.
- Depth 0 / negative values produce surprising full-collapse output instead of the specified passthrough; add input validation at the tool boundary.
- `filter_inner_depth` (viewer.py:16, 178-181) is an extra capability beyond the story, exposed only via the Python API, not via `ToMarkdown`.

## BDD Scenario

```gherkin
Feature: Collapse markdown sections below a depth level
  As a technical writer I view high-level document structure.

  Scenario: View a document at depth 2
    Given a markdown document with headings through level 4
    When the agent calls ToolCall(tool="ToMarkdown", arguments={"source": "doc.md", "collapsed_depth": 2})
    Then headings at levels 1-2 and their content appear normally
    And level-3 headings appear as "<text> 📦" with their content removed
    And deeper headings are hidden entirely

  Scenario: Consecutive collapsed sections
    Given sibling sections all below the depth threshold
    When the document is collapsed
    Then only one marker per collapsed region is emitted

  Scenario: Out-of-range depth
    When the document is collapsed with depth 0
    Then the whole document is collapsed (story expects the original unchanged — gap)
```
