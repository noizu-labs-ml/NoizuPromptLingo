# Review: Load Directives Section with Priority Filtering

- **Story**: `project-management/user-stories/US-201-load-directives-section.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The loading pipeline exists end-to-end: expression parser (`src/npl_mcp/npl/parser.py:148`), resolver (`src/npl_mcp/npl/resolver.py:205`), priority filter (`src/npl_mcp/npl/filters.py:14`), and the `NPLLoad` MCP tool (`src/npl_mcp/launcher.py:237`) wired to `conventions/`. Whole-section loading (`directives`) works against the real conventions data. However, specific-directive loading is broken against the real `conventions/directives.yaml`: its `components:` entries have `name:` but no `slug:` fields, while the resolver matches exclusively on `slug` (`src/npl_mcp/npl/resolver.py:189`). Verified live: `load_npl('directives#table-formatting')` raises `NPLResolveError` ("Available components:" is empty because `get_section_components` also keys on slug, resolver.py:109). Tests (`tests/test_npl_loading.py:416-504`) pass only because they use synthetic YAML that includes `slug:` fields. Priority filtering itself is correctly implemented (inclusive max, missing priority treated as 0, negative max returns nothing).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1.1: Load entire directive section using `directive` | Partially Met | `directive` (singular, as written) raises NPLParseError "Unknown section" (`src/npl_mcp/npl/parser.py:113-116`); `directives` plural loads the full section (`resolver.py:176-185`, verified live) |
| AC-1.2: Load specific directive via `directive#table-formatting` | Not Met | Resolver matches on `slug` (`src/npl_mcp/npl/resolver.py:189`) but `conventions/directives.yaml` components have only `name:` — live call raises NPLResolveError |
| AC-1.3: Priority filtering via `directive#interactive-element:+3` | Partially Met | `filter_by_priority` correct and inclusive (`src/npl_mcp/npl/filters.py:14-64`; tests `tests/test_npl_loading.py:467-504`), but unreachable on real directives data due to the slug lookup failure |
| AC-1.4: Supports all 10 directive identifiers | Not Met | None of the 10 slugs resolve against `conventions/directives.yaml` (no `slug:` fields); live `directives#todo-task` and `directives#table-formatting` both error |
| AC-1.5: Invalid names return clear errors | Partially Met | NPLResolveError raised with section context (`src/npl_mcp/npl/resolver.py:198-203`), but the "Available components:" list is empty on real data, weakening the guidance |

## Gaps / Risks

- Root cause: schema mismatch between `conventions/directives.yaml` (name-keyed components) and the resolver's slug-keyed lookup. Either add `slug:` fields to directives.yaml (matching `conventions/pumps.yaml`, which has them) or make the resolver fall back to `name`.
- Same mismatch likely affects other sections: `conventions/syntax.yaml`, `prefixes.yaml`, `special-sections.yaml`, and `prompt-sections.yaml` also lack component `slug:` fields (verified by grep); `syntax#placeholder` fails live too.
- CLAUDE.md documents `NPLLoad(expression="syntax#placeholder:+2 ...")` as a supported quick path — that example fails against current conventions data.
- Directive identifiers AC list (`table-formatting` … `todo-task`) matches the `name:` values in directives.yaml, confirming intent; only the slug keying blocks them.

## BDD Scenario

```gherkin
Feature: Load NPL directives with priority filtering
  As an AI agent using the NPLLoad MCP tool
  I want to load directives selectively with priority-based examples

  Scenario: Load the entire directives section
    Given the NPL MCP server is running with conventions/ present
    When I call NPLLoad with expression "directives"
    Then markdown for all directive components in YAML order is returned

  Scenario: Load a specific directive with priority filter
    When I call NPLLoad with expression "directives#table-formatting:+1"
    Then today the call fails with NPLResolveError
    And the error lists no available components because directives.yaml components lack slug fields
    And the directive content is not returned

  Scenario: Invalid directive name
    When I call NPLLoad with expression "directives#no-such-directive"
    Then an error naming the section and requesting a valid component is returned
```
