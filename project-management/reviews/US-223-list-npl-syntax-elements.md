# Review: List All NPL Syntax Elements in Document

- **Story**: `project-management/user-stories/US-223-list-npl-syntax-elements.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No per-document syntax-element usage analysis exists in either codebase. The closest adjacent functionality is the REST endpoint `GET /npl/elements` (`src/npl_mcp/api/router.py:1379-1422`), which lists the *catalog* of all NPL components across `conventions/*.yaml` — it takes no file argument and performs no document parsing. The Elixir backend's `NoizuPromptLingua.NPL.Reader` (`backend/lib/noizu_prompt_lingua/npl/reader.ex:90`) similarly lists convention components, not document usage. There is no `npl-elements` CLI entry point, no AST traversal collecting element occurrences with line numbers, and no text/JSON/CSV output formatting, sort, or filter logic. Neither the Python nor Elixir parser produces a document AST suitable for this traversal.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `npl-elements <file>` lists elements used in a document | Not Met | no `npl-elements` in `pyproject.toml:65-73`, `src/`, `tests/`, or backend mix tasks; the `/npl/elements` endpoint ignores documents (`src/npl_mcp/api/router.py:1380-1386`) — no evidence found |
| AC-2: output shows element name, count, line numbers | Not Met | no evidence found |
| AC-3: `--format` flag (text/JSON/CSV) | Not Met | no evidence found |
| AC-4: `--sort` flag (frequency/alphabetical/line-order) | Not Met | no evidence found |
| AC-5: filter by element type | Not Met | no evidence found |
| AC-6: shows element definitions | Partially Met | catalog data does carry `brief`/`friendly_name` (`src/npl_mcp/api/router.py:1405-1406`), but it is not tied to document usage |
| AC-7: acceptable performance for large files | Not Met | no implementation to measure — no evidence found |

## Gaps / Risks

- Depends on the US-080 document parser/AST, which does not exist; the story cannot be built without that prerequisite.
- The name collision between the story's `npl-elements` CLI and the existing `/npl/elements` catalog endpoint is a discoverability trap — reviewers may mistake the endpoint for the story's implementation.
- Test requirements (all output formats, sort options, filtering, nesting edge cases) entirely unaddressed.

## BDD Scenario

```gherkin
Feature: List all NPL syntax elements in a document
  # Not implementable end-to-end today: no document-level element scanner exists.
  Scenario: Developer audits element usage in a prompt document
    Given an NPL document using placeholders, pumps, and qualifiers across 40 lines
    When the developer runs `npl-elements prompt.npl --format json`
    Then the command is not found
    And the only related tool, `GET /npl/elements`, returns the full convention catalog
    And reports nothing about which elements the document actually uses
```
