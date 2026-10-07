# Review: IDE Integration for NPL Syntax Highlighting

- **Story**: `project-management/user-stories/US-222-npl-ide-syntax-highlighting.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`npl-tmlanguage` (`src/npl_mcp/scripts/tmlanguage.py`, wired in `pyproject.toml:68`) generates a TextMate JSON grammar from `conventions/*.yaml` and the output is committed at `tools/npl.tmLanguage.json`. The grammar covers 10 element categories (framework/agent markers, pump tags, directives, prefixes, placeholders, in-fill, qualifiers, highlights, attention) with conventional TextMate scope names (`source.npl`, `keyword.control.framework.npl`, etc. — `tmlanguage.py:90-207`) and is well-tested (`tests/test_tmlanguage.py`). However, coverage is category-level, not all 155 elements; the structural regexes are deliberately hand-scaffolded ("intentionally hand-scaffolded", `tmlanguage.py:13-15`), so pattern generation from syntax.yaml is only partial; and there is no bracket-matching configuration, no VS Code extension packaging (npm), and no Vim/Emacs targets.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-1: generates TextMate/Sublime syntax definition file | Met | `src/npl_mcp/scripts/tmlanguage.py:210-213` renders tmLanguage JSON; committed output `tools/npl.tmLanguage.json` |
| AC-2: highlighting for all 155 NPL syntax elements | Partially Met | grammar covers 10 category-level rules (`tmlanguage.py:95-205`); pump tags from pumps.yaml only; no per-element enumeration of 155 components |
| AC-3: bracket matching for NPL delimiters | Not Met | no `bracketPairs`/folding config in the grammar; TextMate grammars carry no bracket rules here — no evidence found |
| AC-4: scope definitions follow TextMate conventions | Met | `scopeName: source.npl`, `keyword.control.*.npl`, `entity.name.tag.pump.npl`, `markup.bold.*.npl` (`tmlanguage.py:93, 111-204`) |
| AC-5: works with VS Code via TextMate grammar import | Partially Met | the JSON is schema-tagged and importable as a TextMate grammar (`tmlanguage.py:91-94`), but no VS Code extension/package exists — no evidence found for packaging |
| AC-6: extensible for other editors (Vim, Emacs) | Partially Met | grammar is plain JSON (editor-agnostic data), but no generator targets or extension code for Vim/Emacs — no evidence found |
| AC-7: highlighting patterns auto-generated from syntax.yaml | Partially Met | pump tag alternation extracted from `pumps.yaml` (`tmlanguage.py:54-64, 82-88`); structural regexes hand-written by design (`tmlanguage.py:13-15`) |

## Gaps / Risks

- Grammar maintenance is manual: only pumps.yaml is data-driven; adding a new syntax category requires editing hand-scaffolded regexes (`tmlanguage.py:107-205`).
- No bracket matching means the story's "bracket matching" UX claim (description) is unmet even though highlighting works.
- Story's integration-test requirements (VS Code integration, visual regression screenshots) are not covered by `tests/test_tmlanguage.py`, which tests generation only.

## BDD Scenario

```gherkin
Feature: IDE integration for NPL syntax highlighting
  Scenario: Developer regenerates the TextMate grammar after editing pumps.yaml
    Given a modified "conventions/pumps.yaml" with a new pump tag "npl-foo"
    When the developer runs `uv run npl-tmlanguage`
    Then "tools/npl.tmLanguage.json" includes "npl-foo" in the pump tag alternation
    And `uv run npl-tmlanguage --check` exits 0 when up to date

  Scenario: Developer imports the grammar into VS Code
    Given "tools/npl.tmLanguage.json" on disk
    When the developer imports it as a TextMate grammar
    Then NPL markers, pump tags, and placeholders are highlighted
    But bracket matching for NPL delimiters does not activate
    And no packaged VS Code extension is provided
```
