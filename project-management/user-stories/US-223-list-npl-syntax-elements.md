# US-223: List All NPL Syntax Elements in Document

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-223 |
| **Title** | List All NPL Syntax Elements in Document |
| **Priority** | Medium |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-013-npl-syntax-parser.md |

---

## Description

As a developer, I want to list all syntax elements used in a document.

This enables analysis of which NPL syntax elements are used in a document, helping developers understand document structure, find unused elements, and generate documentation of element usage.

---

## Acceptance Criteria

- [ ] **AC-1**: `npl-elements <file>` lists all syntax elements used in document
- [ ] **AC-2**: Output shows element name, count of usage, line numbers
- [ ] **AC-3**: Supports `--format` flag: text (default), JSON, CSV
- [ ] **AC-4**: Supports `--sort` flag: frequency (default), alphabetical, line-order
- [ ] **AC-5**: Can filter by element type (qualifiers, placeholders, fences, etc)
- [ ] **AC-6**: Shows element definitions (brief descriptions)
- [ ] **AC-7**: Performance is acceptable for large files

---

## Technical Notes

- Walking: Parse document, build AST, traverse collecting element nodes
- Deduplication: Count unique elements, track all line numbers
- Output format: Text (tabular), JSON (structured), CSV (spreadsheet)
- Sorting: By usage frequency, alphabetically, or document order
- Filtering: Optional element type filters (qualifiers, placeholders, etc)

---

## Dependencies

- NPL parser (from US-080)
- AST traversal utilities
- Output formatting modules

---

## Test Coverage Requirements

- Unit tests for element collection
- Tests for all output formats
- Tests for sort options
- Tests for filtering
- Tests for performance with large files
- Edge cases: nested elements, element redefinition, comments
- Target coverage: 80%+ for new code paths
