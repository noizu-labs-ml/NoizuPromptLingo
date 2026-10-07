# Review: Build NPL Syntax Pattern Library (155 elements)

- **Story**: `project-management/user-stories/US-087-build-npl-syntax-pattern-library.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The machine-readable substrate is strong: `conventions/*.yaml` (8 files — syntax, declarations, directives, prefixes, prompt-sections, pumps, special-sections) is the declared single source of truth, exposed through the `NPLLoad` expression-DSL and `NPLSpec` structured-specification MCP tools (see repo CLAUDE.md; tools in `src/npl_mcp/`), and rendered into the generated `npl/npl-full.md` with a CI freshness guard (`npl-docs-regen --check`). Element semantics and descriptions therefore exist in structured, machine-validated form. The learning-material layer the story actually asks for is missing: no tagged pattern index (basic/advanced/nested/conditional), no cheat sheet of common combinations, no anti-patterns/common-mistakes guide, no version migration guide, and no evidence of per-element runnable examples validated by a parser. The "155 elements" count is not verifiable from any inventory artifact.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Document all elements with type, syntax, semantics, constraints | Partially Met | structured YAML catalog in `conventions/*.yaml` + NPLLoad/NPLSpec retrieval; no human-facing per-element constraint documentation |
| 2-3 runnable examples per element category | Not Met | no example corpus found beyond inline descriptions |
| Pattern index with tags (basic, advanced, nested, conditional) | Not Met | no evidence found |
| Cheat sheet with common combinations | Not Met | no evidence found (closest artifact is generated `npl/npl-full.md`, a spec dump, not a cheat sheet) |
| Anti-patterns and common mistakes per category | Not Met | no evidence found |
| Migration guide for NPL versions/syntax changes | Not Met | no evidence found |
| All patterns validated against parser | Partially Met | YAML is consumed by `src/npl_mcp/npl/` (loader/parser/resolver) so structural errors surface at load; no explicit validation pass or report |

## Gaps / Risks

- Gap between the engineering catalog and the story's audience: the existing tools serve agents (DSL retrieval), not developers learning NPL — the pattern library's stated purpose (marketing/learning) is unmet.
- `npl-docs-regen --check` gives a precedent for CI-validated docs; an example-validation harness could reuse it.

## BDD Scenario

```gherkin
Feature: Referencing NPL patterns from a learning guide

  Scenario: Developer looks up the placeholder pattern with examples
    When she opens the pattern library index and filters by "basic"
    Then no tagged index or runnable examples exist today; she can only query NPLLoad("syntax#placeholder") for the raw spec snippet

  Scenario: Regenerating the reference doc
    When maintainers run npl-docs-regen --check
    Then npl/npl-full.md is verified fresh against conventions/*.yaml (existing guard passes)
```
