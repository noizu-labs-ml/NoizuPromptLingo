# Review: Load Fences Section with All Layout Strategies

- **Story**: `project-management/user-stories/US-202-load-fences-section.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The layout engine implements all three strategies — YAML_ORDER, CLASSIC, GROUPED (`src/npl_mcp/npl/layout.py:16-20`, dispatch at `layout.py:46-54`) — and is selectable per request via the `NPLLoad` tool's `layout` parameter (`src/npl_mcp/launcher.py:270-277`). The parser and resolver recognize a `fences` section (`src/npl_mcp/npl/parser.py:42`; `src/npl_mcp/npl/resolver.py:45` maps it to `fences.yaml`). However, `conventions/fences.yaml` does not exist (the story's own Open Question Q1 anticipated this), so loading fences fails outright: verified live, `load_npl('fences')` raises `NPLResolveError: Section file not found: fences.yaml`. The layout strategies are Met at the engine level and demonstrable for the seven sections that do have YAML files; no fence content can be rendered through any layout today.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-2.1: Load all fences using `fences` | Not Met | `conventions/fences.yaml` missing; live call raises NPLResolveError "Section file not found: fences.yaml" (`src/npl_mcp/npl/resolver.py:80-84`) |
| AC-2.2: Works with yaml-order layout | Met | `layout.py:56-68` preserves component order; default strategy (`layout.py:26`), verified live for `pumps` (33k chars, definition order) |
| AC-2.3: Works with classic layout (categories) | Met | `layout.py:70-94` groups by first label with "Uncategorized" fallback and `## Category` headings |
| AC-2.4: Works with grouped layout | Met | `layout.py:96-120` groups by section type with `## Section` headings |
| AC-2.5: Output is valid markdown for all layouts | Met | `format_component` emits headings/lists/emphasis (`layout.py:122-170`); untestable for fences specifically (no data) |
| AC-2.6: Layout configurable per request | Met | `NPLLoad(layout=...)` maps yaml_order/classic/grouped (`src/npl_mcp/launcher.py:270-277`) |

## Gaps / Risks

- `conventions/fences.yaml` was never created — the story's dependency explicitly flagged this ("may need creation").
- Because fences.yaml is absent, the entire `fences` section is a trap for callers: the parser accepts it (`parser.py:42`) but resolution always fails.
- Classic layout derives categories from the first `labels` entry; if fences.yaml is created without labels, everything lands in "Uncategorized" (answers Open Question Q2 only implicitly).

## BDD Scenario

```gherkin
Feature: Load fence definitions with layout strategies
  As a documentation generator using the NPLLoad MCP tool
  I want fences rendered in yaml-order, classic, or grouped layouts

  Scenario: Load all fences
    Given the NPL MCP server is running
    When I call NPLLoad with expression "fences"
    Then today the call fails with "Section file not found: fences.yaml"
    And no fence markdown is returned

  Scenario: Switch layout strategy for a loadable section
    Given the pumps section exists in conventions/pumps.yaml
    When I call NPLLoad with expression "pumps" and layout "grouped"
    Then components are grouped under a "## Pumps" heading
    When I call NPLLoad with expression "pumps" and layout "classic"
    Then components are grouped under heading-cased first-label categories
    And both outputs are valid markdown
```
