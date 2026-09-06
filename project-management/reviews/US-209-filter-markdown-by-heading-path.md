# Review: Filter Markdown by Heading Path

- **Story**: `project-management/user-stories/US-209-filter-markdown-by-heading-path.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Heading-path filtering is implemented in `HeadingFilter` (`src/npl_mcp/markdown/filters/heading.py`). It parses markdown into a hierarchical section tree (`_parse_sections`, heading.py:195), navigates `>`-separated paths (heading.py:117-147), supports wildcards (heading.py:125-132), case-insensitive and normalized-name matching (heading.py:262-272), and serializes matched subtrees back to markdown (heading.py:283-308). It is exposed via `apply_filter` (`src/npl_mcp/markdown/filters/__init__.py:50`) and `MarkdownViewer.view` (`src/npl_mcp/markdown/viewer.py:10`). The one gap: level selectors (`h1`..`h6`) return only the FIRST matching section, not all headings at that level (heading.py:254-259; confirmed by `tests/test_heading_filter.py:143`), and a bare level selector only searches the current tree level, not recursively (tests/test_heading_filter.py:161-169). Confidence: high — implementation and tests were read directly.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: Filter by heading name (case-insensitive) | Met | `src/npl_mcp/markdown/filters/heading.py:268-272` (raw-text lower-case match + kebab-case normalized match); `tests/test_heading_filter.py:97-112` |
| AC-2: Nested path navigation `"Overview > Installation"` | Met | `src/npl_mcp/markdown/filters/heading.py:117` (split on `>`) and traversal at heading.py:122-147; `tests/test_heading_filter.py:197-260` |
| AC-3: Wildcard for all children `"API > *"` | Met | `src/npl_mcp/markdown/filters/heading.py:124-132`; `tests/test_heading_filter.py:262-295` |
| AC-4: Filter by heading level `h1`..`h6` | Partially Met | `src/npl_mcp/markdown/filters/heading.py:254-259` accepts `h1`-`h6` but returns only the first matching section; `tests/test_heading_filter.py:143-151` ("h1 returns first match only") |
| AC-5: Full matched section content with all children | Met | `src/npl_mcp/markdown/filters/heading.py:283-308` (`_sections_to_markdown` recurses into children); `tests/test_heading_filter.py:213-221` |
| AC-6: Error for missing sections `"# Error: Section not found: {name}"` | Met | `src/npl_mcp/markdown/filters/heading.py:142`; context mode error in `src/npl_mcp/markdown/viewer.py:63`; `tests/test_markdown_viewer.py:177` |
| AC-7: Handles sections with no content gracefully | Met | Empty `content` list handled by heading.py:299-300; `tests/test_heading_filter.py:312-316, 442-454` |

## Gaps / Risks

- Level selectors match only the first section at that level, contradicting the natural reading of "filter by heading level" (see US-210, which makes "all headings" explicit).
- Bare level selectors (e.g. `h2` on a doc whose h2s are nested under an h1) fail to match unless the level heading sits at the traversal level (tests/test_heading_filter.py:161-169) — surprising behavior for callers.
- `_find_section`'s second-pass recursive name search can match a heading at an unexpected depth, so `"A > B"` may match a `B` nested deeper than intended.
- Error path in viewer context mode reports the whole selector string, not the failing path segment (viewer.py:63) — cosmetic divergence from the AC format.

## BDD Scenario

```gherkin
Feature: Filter markdown by heading path
  As an AI agent I extract document sections by heading hierarchy.

  Scenario: Extract a nested section by name
    Given a large markdown document converted to a section tree
    When the agent calls ToolCall(tool="ToMarkdown", arguments={"source": "docs/api.md", "filter": "Overview > Installation", "filtered_only": true})
    Then only the "Installation" section with its full subtree is returned
    And the match is case-insensitive

  Scenario: Expand an entire section subtree with a wildcard
    When the agent filters with "API > *"
    Then all child sections under "API" are returned in document order

  Scenario: Section does not exist
    When the agent filters with a selector matching no heading
    Then the output is "# Error: Section not found: <segment>"
```
