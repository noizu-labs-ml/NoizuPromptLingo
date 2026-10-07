# Review: NPL Syntax Validation via CLI with Error Reporting

- **Story**: `project-management/user-stories/US-220-npl-syntax-validation-cli.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No `npl-validate` command exists in either codebase. The Python package's console scripts (`pyproject.toml:65-73`) expose only `npl-mcp`, `npl-docs-regen`, `npl-tmlanguage`, and markdown/git tools; `src/npl_mcp/npl/parser.py` parses load *expressions* (component selectors), not NPL documents, and `src/npl_mcp/npl/exceptions.py` carries no line/column position data. The Elixir backend's `NoizuPromptLingua.NPL.Parser` (backend `lib/noizu_prompt_lingua/npl/parser.ex`) similarly parses expressions only. `src/npl_mcp/skills/validator.py` validates skill structure, not NPL documents. No error-formatting, exit-code, or multi-file validation logic was found anywhere.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `npl-validate` CLI validates NPL documents | Not Met | no `npl-validate` in `pyproject.toml:65-73`, `src/`, `tests/`, or backend `lib/mix/tasks/` — no evidence found |
| AC-2: errors include file/line/column | Not Met | `src/npl_mcp/npl/exceptions.py` has no position fields; no evidence found |
| AC-3: errors show problematic line with context | Not Met | no evidence found |
| AC-4: multiple file arguments | Not Met | no evidence found |
| AC-5: exit code reflects validation status | Not Met | no evidence found |
| AC-6: works with all NPL document types | Not Met | no document-level validation exists — no evidence found |
| AC-7: < 1s for 10MB | Not Met | no validator to measure — no evidence found |

## Gaps / Risks

- Depends on US-080 NPL parser; neither codebase has a document-level parser capable of producing line/column diagnostics — the prerequisite itself appears incomplete.
- `npl-docs-regen --check` covers only regeneration staleness of `npl/npl-full.md`, not user-authored document validation (easy to confuse as adjacent functionality; it is not).
- Test coverage requirements (BOM/CRLF/EOF edge cases) are entirely unaddressed.

## BDD Scenario

```gherkin
Feature: NPL syntax validation via CLI
  # Not implementable end-to-end today: the npl-validate command does not exist.
  Scenario: Developer validates a malformed NPL document
    Given an NPL document "agent.md" containing an unterminated pump tag on line 12
    When the developer runs `npl-validate agent.md`
    Then the command fails with "command not found"
    And no line/column diagnostics are produced by any existing tool
```
