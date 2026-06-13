# US-213: Combine Filtering and Collapsing in Pipeline

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-213 |
| **Title** | Combine Filtering and Collapsing in Pipeline |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | prd-markdown-tools.md |

---

## Description

As a technical writer, I want to combine filtering and collapsing so I can see a filtered view with controlled depth.

This enables sophisticated document navigation: extract a specific section (filter) and view it with controlled depth (collapse), all in a single operation for focused reading and analysis.

---

## Acceptance Criteria

- [ ] **AC-1**: `md-view` tool supports `--filter` and `--depth` together
- [ ] **AC-2**: `view-md` tool supports `--filter` and `--depth` together
- [ ] **AC-3**: `view_markdown` MCP tool supports both parameters simultaneously
- [ ] **AC-4**: Pipeline order: apply filter first, then collapse on filtered result
- [ ] **AC-5**: Filter and collapse work independently (either can be used alone)
- [ ] **AC-6**: Combined operation maintains correct markdown structure
- [ ] **AC-7**: Performance remains acceptable for large documents

---

## Technical Notes

- Pipeline implementation: Call apply_filter() first, then collapse()
- Order matters: Filter selects content, collapse reduces depth of filtered result
- Both operations preserve markdown validity
- Filtered result may be smaller than full document, so collapse logic adapts
- Example: `view-md doc.md --filter "API" --depth 2` → select API section, show only 2 levels

---

## Dependencies

- HeadingFilter class (FR-3)
- MarkdownViewer class (FR-7)
- Filter and collapse integration in viewer

---

## Test Coverage Requirements

- Integration tests for filter + collapse combination
- Tests for all filter types (heading name, path, level) with collapse
- Tests for output correctness
- Tests for edge cases (empty filtered result, no sections at depth)
- Performance tests with large documents
- Target coverage: 80%+ for new code paths
