# Review: Filter Markdown by Heading Level Selectors

- **Story**: `project-management/user-stories/US-210-filter-by-heading-level.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Level selectors are handled inside `HeadingFilter._find_section` (`src/npl_mcp/markdown/filters/heading.py:253-259`): a selector matching `^h[1-6]$` filters the current section list by level and returns the FIRST match only, embedded in the path-navigation flow (heading.py:122-147). Tests explicitly document the first-match-only semantics (`tests/test_heading_filter.py:143-151`) and the current-level-only scope (tests/test_heading_filter.py:161-169). The story's core promise — "h1 returns ALL level-1 headings", "h2 returns ALL level-2 headings" — is not met: there is no code path that collects every section at a given level. Invalid levels fall through to name matching and yield the section-not-found error. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: Supports level selectors `h1`..`h6` | Met | `src/npl_mcp/markdown/filters/heading.py:254` (`re.match(r"^h[1-6]$", selector)`); all six accepted by syntax |
| AC-2: `h1` returns all level-1 headings | Not Met | `src/npl_mcp/markdown/filters/heading.py:255-259` returns the first matching section only; `tests/test_heading_filter.py:143-151` ("h1 returns first match only") |
| AC-3: `h2` returns all level-2 headings | Not Met | Same first-match code path (heading.py:255-259); `tests/test_heading_filter.py:153-159` asserts only one h2's content |
| AC-4: Level filtering returns matched headings with immediate content | Met (for the single match) | `_sections_to_markdown` includes `content` lines — `src/npl_mcp/markdown/filters/heading.py:294-300`; `tests/test_heading_filter.py:137-141` |
| AC-5: Returns headings in document order | Partially Met | Single match trivially ordered; children lists preserve document order (heading.py:229-234), but "all headings" ordering is unobservable since only one is returned |
| AC-6: Invalid levels (h0, h7) return error messages | Met | Regex `^h[1-6]$` (heading.py:254) rejects them → falls to name match → `"# Error: Section not found: h0"` (heading.py:142); `tests/test_heading_filter.py:171-176` |
| AC-7: Error for documents with no headings at specified level | Met | `tests/test_heading_filter.py:161-169, 171-176` — "Error"/"not found" output |

## Gaps / Risks

- The headline behavior (extract ALL sections at a level) is missing; agents wanting "all h2 sections" get one section. This is the story's primary purpose per the description.
- Level selectors do not search recursively (unlike name selectors, which do a second recursive pass at heading.py:274-280) — inconsistent semantics between selector kinds.
- Error text for invalid levels is a section-not-found message, not a level-validation message; slightly misleading diagnostics.

## BDD Scenario

```gherkin
Feature: Filter markdown by heading level selectors
  As an AI agent I navigate documents by heading depth.

  Scenario: Select by level
    Given a markdown document with headings at multiple levels
    When the agent calls ToolCall(tool="ToMarkdown", arguments={"source": "doc.md", "filter": "h2", "filtered_only": true})
    Then only the FIRST level-2 heading with its content is returned
    And all other level-2 headings are NOT returned (gap vs. story intent)

  Scenario: Invalid level selector
    When the agent filters with "h7"
    Then the response is "# Error: Section not found: h7"

  Scenario: No headings at requested level
    Given a document with no level-2 headings
    When the agent filters with "h2"
    Then an error/not-found message is returned
```
