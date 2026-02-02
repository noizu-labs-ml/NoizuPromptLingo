# US-209: Filter Markdown by Heading Path

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-209 |
| **Title** | Filter Markdown by Heading Path |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-001 (AI Agent) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As an AI agent, I want to filter markdown by heading path so I can extract relevant sections from large docs.

This enables precise extraction of document sections by heading hierarchy: agents can select specific sections like "Overview > Installation" or use wildcards like "API > *" to extract entire section subtrees.

---

## Acceptance Criteria

- [ ] **AC-1**: Can filter by heading name (case-insensitive): `"API Reference"`
- [ ] **AC-2**: Can filter by nested path navigation: `"Overview > Installation"`
- [ ] **AC-3**: Supports wildcard for all children at level: `"API > *"`
- [ ] **AC-4**: Can filter by heading level: `h1`, `h2`, ... `h6`
- [ ] **AC-5**: Returns full matched section content with all children
- [ ] **AC-6**: Returns error message for missing sections: `"# Error: Section not found: {name}"`
- [ ] **AC-7**: Handles sections with no content gracefully

---

## Technical Notes

- Parsing: Convert markdown to hierarchical section tree
- Section tracking: level, text, content lines, children array
- Path navigation: Split by `>`, traverse tree depth-first
- Wildcard handling: Return all children at current level
- Content extraction: Return matched section with full subtree

---

## Dependencies

- HeadingFilter class (FR-3)
- Markdown parsing utilities
- Section tree data structure

---

## Test Coverage Requirements

- Unit tests for heading parsing
- Tests for path navigation
- Tests for wildcard expansion
- Tests for heading level matching
- Tests for missing sections
- Edge cases: empty sections, deep nesting, special characters in headings
- Target coverage: 80%+ for new code paths
