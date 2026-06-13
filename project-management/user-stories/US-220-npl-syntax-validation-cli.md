# US-220: NPL Syntax Validation via CLI with Error Reporting

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-220 |
| **Title** | NPL Syntax Validation via CLI with Error Reporting |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-013-npl-syntax-parser.md |

---

## Description

As a developer, I want CLI validation with clear error messages and line numbers.

This enables developers to validate NPL documents from the command line with precise error reporting, showing exactly where syntax problems occur with line and column information for quick debugging.

---

## Acceptance Criteria

- [ ] **AC-1**: `npl-validate` CLI command validates NPL documents
- [ ] **AC-2**: Error messages include file path, line number, column number
- [ ] **AC-3**: Error messages show the problematic line with context
- [ ] **AC-4**: Supports multiple file arguments
- [ ] **AC-5**: Exit code reflects validation status (0 = valid, non-zero = invalid)
- [ ] **AC-6**: Works with all NPL document types
- [ ] **AC-7**: Performance is acceptable for large files (< 1s for 10MB)

---

## Technical Notes

- Error format: `{filename}:{line}:{column}: {error_type}: {message}`
- Context display: Show 1-2 lines before/after error
- Multiple errors: Report all errors, not just first
- Unicode handling: Proper column counting with multibyte characters
- Exit codes: 0 (valid), 1 (syntax error), 2 (file error)

---

## Dependencies

- NPL parser (from US-080)
- CLI framework (Click or similar)
- Error reporting utilities

---

## Test Coverage Requirements

- Unit tests for error message formatting
- Tests for line/column accuracy
- Tests for context display
- Tests for multiple file handling
- Tests for large file performance
- Edge cases: BOM, CRLF, missing newline at EOF
- Target coverage: 80%+ for new code paths
