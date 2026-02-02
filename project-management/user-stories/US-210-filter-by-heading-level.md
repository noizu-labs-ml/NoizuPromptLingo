# US-210: Filter Markdown by Heading Level Selectors

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-210 |
| **Title** | Filter Markdown by Heading Level Selectors |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-001 (AI Agent) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As an AI agent, I want to use heading level selectors (h1, h2) so I can navigate document structure.

This enables navigation of documents by heading hierarchy level: agents can extract all top-level sections (h1), subsections (h2), or any specific depth level for structural analysis and content organization.

---

## Acceptance Criteria

- [ ] **AC-1**: Supports heading level selectors: `h1`, `h2`, `h3`, `h4`, `h5`, `h6`
- [ ] **AC-2**: `h1` returns all level-1 headings
- [ ] **AC-3**: `h2` returns all level-2 headings
- [ ] **AC-4**: Filtering by level returns matched headings with their immediate content
- [ ] **AC-5**: Returns headings in document order
- [ ] **AC-6**: Invalid heading levels (h0, h7, etc) return error messages
- [ ] **AC-7**: Returns error for documents with no headings at specified level

---

## Technical Notes

- Heading level detection: Parse `^#{1,6}\s+` regex pattern
- Level matching: Count number of `#` characters
- Content extraction: From heading to next heading of same or higher level
- Output: Combined markdown with matched headings

---

## Dependencies

- HeadingFilter class (FR-3)
- Markdown regex parsing
- Level detection utilities

---

## Test Coverage Requirements

- Unit tests for heading level detection
- Tests for h1-h6 selectors
- Tests for content extraction by level
- Tests for heading ordering
- Tests for documents with no matching levels
- Edge cases: nested levels, mixed levels, missing levels
- Target coverage: 80%+ for new code paths
