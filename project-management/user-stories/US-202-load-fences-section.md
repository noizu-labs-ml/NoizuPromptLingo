# US-202: Load Fences Section with All Layout Strategies

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-202 |
| **Title** | Load Fences Section with All Layout Strategies |
| **Priority** | High |
| **Story Points** | 3 |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | PRD-012: NPL Advanced Loading Extension |

---

## Description

As a documentation generator, I want to load fence definitions with all three layout strategies (yaml-order, classic, grouped).

This enables flexible formatting of fence definitions for different documentation contexts, allowing the output to be optimized for readability or logical organization.

---

## Acceptance Criteria

- [ ] **AC-2.1**: Can load all fences using expression `fences`
- [ ] **AC-2.2**: Works with `yaml-order` layout (preserves YAML definition order)
- [ ] **AC-2.3**: Works with `classic` layout (with fence categories if defined)
- [ ] **AC-2.4**: Works with `grouped` layout (grouped by type/category)
- [ ] **AC-2.5**: Output is valid markdown for all layout strategies
- [ ] **AC-2.6**: Layout strategy is configurable per request

---

## Technical Notes

- Layout engine must support three strategies: YAML_ORDER, CLASSIC, GROUPED
- YAML_ORDER: preserve definition order from `fences.yaml`
- CLASSIC: organize by category/labels if present
- GROUPED: group by type (all similar fences together)
- All outputs must be valid markdown with proper headings and structure

---

## Dependencies

- Layout engine implementation (FR-4)
- Section resolver for fences (FR-2)
- `npl/fences.yaml` file (may need creation)

---

## Test Coverage Requirements

- Unit tests for each layout strategy
- Markdown validity tests for all outputs
- Edge cases: empty fence list, fences without categories
- Target coverage: 80%+ for layout engine code paths

---

## Open Questions

- Q1: Should `fences.yaml` be created if it doesn't exist yet?
- Q2: What are the default categories for CLASSIC layout?
