# Review: Skip Already-Loaded Resources Using Flags

- **Story**: `project-management/user-stories/US-224-skip-loaded-resources-flag.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A `skip` mechanism exists in the core loader: `load_npl(..., skip=...)` folds skip expressions into expression subtractions (`src/npl_mcp/npl/loader.py:22, 71-84`), tested in `tests/test_npl_loading.py:1355-1391` (explicitly tagged "US-224"). The persona CLI's `get` command also accepts `--skip` (`src/npl_persona/cli.py:85-86`), honored in `get_persona` (`src/npl_persona/persona.py:184-206`). The Elixir backend mirrors the loader-level skip via `fold_skip` (`backend/lib/noizu_prompt_lingua/npl/loader.ex:12, 22-38`). Missing: any session-persistent "already loaded" registry (`--skip-loaded`), an `--only` include filter, glob/case-insensitive matching, skip-reason logging, and conflict detection between skip and only — skips apply silently and callers must pass the skip set themselves.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: `--skip` flag specifies resources to skip | Met | `load_npl(skip=...)` excluding named components (`src/npl_mcp/npl/loader.py:71-84`; tests `tests/test_npl_loading.py:1362-1384`); persona CLI `--skip` (`src/npl_persona/cli.py:85-86`) |
| AC-2: `--skip-loaded` skips previously-loaded resources from session memory | Not Met | no session-scoped loaded-resource registry in either codebase; persona `--skip` requires the caller to supply the set (`src/npl_persona/persona.py:192-206`) — no evidence found |
| AC-3: `--only` loads ONLY specified resources | Not Met | no `--only` flag or equivalent in `src/npl_persona/`, `src/npl_mcp/npl/`, or backend `lib/noizu_prompt_lingua/npl/` — no evidence found |
| AC-4: case-insensitive matching and glob patterns | Not Met | skip terms are parsed as exact component expressions via `parse_expression` (`loader.py:79-84`); no fnmatch/glob or case-folding — no evidence found |
| AC-5: skipped resources logged with reason | Not Met | skip is folded silently into subtractions (`loader.py:71-84`); no log of what was skipped or why — no evidence found |
| AC-6: works with all resource loaders (npl-load, npl-persona, npl-session) | Partially Met | npl-load and npl-persona supported (`loader.py:22`; `cli.py:85-86`); no npl-session loader exposes skip — no evidence found |
| AC-7: skip + only conflict raises error | Not Met | `--only` does not exist, so no conflict detection; skips never error (`loader.py:71-84`) — no evidence found |

## Gaps / Risks

- The story's central value — *automatically* skipping already-loaded resources — is unmet: every skip is caller-supplied, so duplication avoidance depends on the caller's bookkeeping.
- Empty skip list is a no-op rather than an error or warning (`tests/test_npl_loading.py:1385-1391`); story edge cases (empty patterns, mutual conflicts) unhandled.
- Backend (`Elixir`) skip duplicates the Python logic but shares none of the story's session-tracking ambitions; two implementations to keep in sync if `--skip-loaded` is added.

## BDD Scenario

```gherkin
Feature: Skip already-loaded resources using flags
  Scenario: Developer loads syntax while skipping one component
    Given the NPL conventions directory
    When the developer calls load_npl("syntax", skip="syntax#literal-string")
    Then the result excludes the "syntax#literal-string" component

  Scenario: Developer relies on session memory to avoid double loading
    Given a component loaded earlier in the session
    When the developer loads with --skip-loaded
    Then the flag is not recognized by any loader
    And the component is loaded a second time

  Scenario: Developer combines --skip and --only
    When the developer passes both --skip agent and --only tool
    Then no conflict error is raised (the --only flag does not exist)
```
