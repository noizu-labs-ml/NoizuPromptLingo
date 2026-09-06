# Review: Load Pumps Section with Complex Expressions

- **Story**: `project-management/user-stories/US-203-load-pumps-section.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Pump loading works well for whole-section, single-component, space-separated multi-component, subtraction, and priority-filtered loads. `conventions/pumps.yaml` is the one large section whose components carry `slug:` fields, so slug lookup succeeds (verified live: `pumps` returns ~33k chars; `pumps#chain-of-thought` returns component markdown). The grammar does NOT support the `+` operator for combining components within a term — terms are whitespace-separated (`src/npl_mcp/npl/parser.py:67-71,178-200`), so the story's AC-3.3 form `pumps#intent-declaration+chain-of-thought` raises NPLParseError (verified live); the supported equivalent is repeating the section (`pumps#a pumps#b`, documented at `src/npl_mcp/launcher.py:253`). Three of the seven AC-3.6 slugs (`self-assessment`, `tangential-exploration`, `emotional-context`) do not exist in pumps.yaml; nearest actual pumps include `plan-of-action`, `reflection`, `mood`, `thought-bubble`, `mode-of-thought`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-3.1: Load all pumps via `pumps` | Met | Verified live — full section rendered in YAML order (`resolver.py:176-185`) |
| AC-3.2: Load specific pump via `pumps#chain-of-thought` | Met | Slug match (`src/npl_mcp/npl/resolver.py:188-196`); verified live, ~1871 chars returned |
| AC-3.3: Combine pumps with `+` (`pumps#intent-declaration+chain-of-thought`) | Not Met | Parser rejects `+` inside a term (NPLParseError, verified live); grammar is whitespace-separated (`src/npl_mcp/npl/parser.py:67-71`); workaround: `pumps#intent-declaration pumps#chain-of-thought` |
| AC-3.4: Subtract pumps via `-` | Met | `parser.py:187-196` parses subtractions; `resolver.py:232-251` removes or warns for non-loaded; live `pumps -pumps#tangential-exploration` succeeds (warning-only for missing slug) |
| AC-3.5: Priority filter via `pumps#self-assessment:+1` | Partially Met | Priority mechanism correct (`filters.py:14-64`; per-component application `resolver.py:143-146`), but `self-assessment` is not a real pump slug — live call errors |
| AC-3.6: All seven pump identifiers match slugs | Partially Met | 4/7 exist in `conventions/pumps.yaml` (intent-declaration, chain-of-thought, critical-analysis, evaluation-framework); self-assessment, tangential-exploration, emotional-context absent |

## Gaps / Risks

- The `+` concatenation form from the story (and AC-3.3/complex example) is a parse error rather than a supported or clearly-deprecated syntax — either extend the grammar or update the story/docs.
- Subtraction of a non-existent pump silently warns and succeeds (`resolver.py:247-251`) — matches US-204's spec but means typos in subtractions are easy to miss (e.g., AC-3.4's example subtracts a slug that doesn't exist, yet "works").
- Story slug list appears to predate the current pumps.yaml taxonomy; PRD/story alignment should be refreshed.

## BDD Scenario

```gherkin
Feature: Load reasoning pumps with complex expressions
  As a prompt engineer using the NPLLoad MCP tool
  I want to control which reasoning pumps load and at what priority

  Scenario: Load specific pumps
    When I call NPLLoad with expression "pumps#chain-of-thought pumps#plan-of-action"
    Then markdown for both pumps is returned in request order

  Scenario: Load with priority filter
    When I call NPLLoad with expression "pumps#chain-of-thought:+1"
    Then only that pump's examples with priority <= 1 are included

  Scenario: Subtract a pump
    When I call NPLLoad with expression "pumps -pumps#mood"
    Then the mood pump is excluded and all other pumps are returned

  Scenario: Plus-combined term (story form)
    When I call NPLLoad with expression "pumps#intent-declaration+chain-of-thought"
    Then today the call fails with NPLParseError: invalid expression format
```
