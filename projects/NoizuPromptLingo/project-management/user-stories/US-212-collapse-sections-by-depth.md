# US-212: Collapse Markdown Sections Below Depth Level

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-212 |
| **Title** | Collapse Markdown Sections Below Depth Level |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a technical writer, I want to collapse sections below a certain depth so I can focus on high-level structure.

This enables depth-controlled markdown viewing: documents can be displayed with only top-level headings (depth 1), subsections (depth 2), or any level up to full detail, with collapsed sections replaced by `### [Collapsed]` markers.

---

## Acceptance Criteria

- [ ] **AC-1**: `--depth` flag accepts values 1-6
- [ ] **AC-2**: Headings below specified depth are replaced with `### [Collapsed]` marker
- [ ] **AC-3**: Consecutive collapsed sections emit single marker
- [ ] **AC-4**: Collapsed content is completely removed from output
- [ ] **AC-5**: Original depth is preserved in output (not collapsed headings appear normally)
- [ ] **AC-6**: Invalid depth (0, 7+) returns original document without collapsing
- [ ] **AC-7**: Works with both CLI tools and MCP tools

---

## Technical Notes

- Algorithm: Parse lines, detect headings by `^#{1,6}\s+` pattern
- Level tracking: Count `#` characters
- Collapse logic: If heading level > depth, replace content lines with marker
- Marker consolidation: Track consecutive collapsed sections, emit one marker
- Edge cases: Empty sections, sections at depth boundary, no headings

---

## Dependencies

- MarkdownViewer class (FR-7)
- Heading detection regex
- Line-by-line content processing

---

## Test Coverage Requirements

- Unit tests for depth calculation
- Tests for collapse behavior at each depth level (1-6)
- Tests for marker consolidation
- Tests for edge cases (invalid depth, no headings, empty sections)
- Integration tests with filtering
- Target coverage: 80%+ for new code paths
