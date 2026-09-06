# Review: Build NPL Syntax Parser

- **Story**: `project-management/user-stories/US-080-build-npl-syntax-parser.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

What exists is a narrow expression parser, not the NPL syntax parser the story describes. `src/npl_mcp/npl/parser.py` (209 lines) parses the NPL *loading expression* DSL (`"syntax#placeholder:+2 directives -syntax#literal"`) into `NPLExpression`/`NPLComponent` structures with good, actionable error messages (`parser.py:88-138`) and solid test coverage in `tests/test_npl_loading.py`. It does NOT parse NPL prompt syntax into a general AST: there are no directive/reference/conditional node types, no line/column tracking (errors carry no position), no escape/multi-line handling, and no streaming. The "155 syntax elements" live as YAML conventions data (`conventions/*.yaml`) consumed via `NPLLoad`/`NPLSpec` (`src/npl_mcp/npl/loader.py`, `resolver.py`) — rendering, not parsing of arbitrary NPL documents. Confidence: high that the story's parser as specified is not implemented; the story's own Implementation Notes ("no parser code exists") predate the expression parser but its gap statement still holds for the full parser.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Parser supports all 155 NPL syntax elements with proper precedence | Not Met | `src/npl_mcp/npl/parser.py:16-24` grammar covers only section/component/priority expression terms |
| Produces AST with node types (directive, reference, conditional, etc.) | Partially Met | dataclass AST exists but only for expression components (`parser.py:51-64`); no directive/reference/conditional node types |
| Line number and column tracking for error reporting | Not Met | `NPLParseError` raised with message strings only (`parser.py:88-138`); no position data captured |
| Handles escaped characters, multi-line constructs, edge cases | Not Met | expression parser splits on whitespace (`parser.py:177-178`); no escape sequences or multi-line constructs |
| Meaningful error messages with suggested fixes | Met | `parser.py:88-100` ("Use '#' to separate section from component... Example: syntax#placeholder"), `:113-116` (valid-sections list), `:124-137` (priority format hints); covered in `tests/test_npl_loading.py` |
| 95%+ test coverage for parser logic | Partially Met | thorough tests for the expression parser (`tests/test_npl_loading.py` includes error paths); coverage of the *story's* parser scope is N/A — the parser doesn't exist |
| <100ms for typical agent prompts (under 50KB) | Not Met | no performance test or benchmark found |

## Gaps / Risks

- Naming collision risk: `npl.parser` already occupies the name for the expression DSL; the real syntax parser will need a distinct module or a namespace decision.
- No position tracking anywhere in the NPL module — retrofitting line/col later means reworking the error type, not just adding messages.
- The story's coverage/performance criteria are unverifiable until a real parser exists; treat them as blocking definition-of-done for the future implementation.

## BDD Scenario

```gherkin
Feature: Parse NPL syntax into a structured AST
  Scenario: Load conventions via the expression DSL (works today)
    Given the conventions YAML directory is the source of truth
    When the agent calls NPLLoad with "syntax#placeholder:+2 directives -syntax#literal"
    Then parse_expression returns additions and subtractions with section/component/priority
    And an invalid term like "syntax@placeholder" fails with a suggested-fix message
  Scenario: Parse a full NPL prompt document
    When a 50KB agent prompt containing directives, references, and conditionals is parsed
    Then a typed AST is produced with line/column positions on every node
    And a malformed construct yields an error naming the line, the problem, and a suggested fix
    (no such parser exists today — gap)
```
