# US-222: IDE Integration for NPL Syntax Highlighting

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-222 |
| **Title** | IDE Integration for NPL Syntax Highlighting |
| **Priority** | Medium |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-013-npl-syntax-parser.md |

---

## Description

As a developer, I want IDE integration for NPL syntax highlighting.

This enables better developer experience when working with NPL files in modern IDEs: syntax highlighting, bracket matching, auto-completion, and hover documentation for NPL syntax elements.

---

## Acceptance Criteria

- [ ] **AC-1**: Generates TextMate/Sublime syntax definition file
- [ ] **AC-2**: Syntax highlighting for all 155 NPL syntax elements
- [ ] **AC-3**: Bracket matching for NPL delimiters (parentheses, brackets, etc)
- [ ] **AC-4**: Scope definitions follow TextMate conventions
- [ ] **AC-5**: Works with VS Code via TextMate grammar import
- [ ] **AC-6**: Can be extended for other editors (Vim, Emacs, etc)
- [ ] **AC-7**: Highlighting patterns are auto-generated from syntax.yaml

---

## Technical Notes

- TextMate syntax format: PLIST/XML or JSON format
- Scope naming: `source.npl`, `keyword.operator.npl`, `string.quoted.npl`, etc.
- Pattern generation: Convert syntax.yaml to regex patterns
- Auto-generation: Scripts in `.editor/` directory
- Distribution: npm package for VS Code extension

---

## Dependencies

- NPL syntax.yaml definitions
- TextMate syntax format generator
- IDE extension packaging tools

---

## Test Coverage Requirements

- Unit tests for pattern generation
- Tests for all syntax element types
- Integration tests with VS Code
- Tests for highlighting accuracy
- Visual regression tests (screenshots of highlighting)
- Edge cases: nested elements, escaped characters, ambiguous patterns
- Target coverage: 80%+ for new code paths
