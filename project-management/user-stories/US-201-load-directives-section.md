# US-201: Load Directives Section with Priority Filtering

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-201 |
| **Title** | Load Directives Section with Priority Filtering |
| **Priority** | High |
| **Story Points** | 5 |
| **Status** | Draft |
| **Related Personas** | P-001 (AI Agent), P-003 (Vibe Coder) |
| **Related PRD** | PRD-012: NPL Advanced Loading Extension |

---

## Description

As a user, I want to load NPL directives using expressions like `directive#table-formatting:+2` to get the table-formatting directive with priority 0-2 examples.

This enables selective loading of NPL directive components with priority-based example filtering, allowing users to control the verbosity and complexity of loaded directives.

---

## Acceptance Criteria

- [ ] **AC-1.1**: Can load entire directive section using expression `directive`
- [ ] **AC-1.2**: Can load specific directive using expression `directive#table-formatting`
- [ ] **AC-1.3**: Can filter by priority using expression `directive#interactive-element:+3`
- [ ] **AC-1.4**: Supports all directive identifiers:
  - `table-formatting`
  - `diagram-visualization`
  - `temporal-control`
  - `template-integration`
  - `interactive-element`
  - `identifier-management`
  - `explanatory-note`
  - `section-reference`
  - `explicit-instruction`
  - `todo-task`
- [ ] **AC-1.5**: Invalid directive names return clear error messages

---

## Technical Notes

- Parser must recognize `directives` section identifier
- Resolver must map directive slugs to YAML component definitions
- Priority filter must exclude examples with priority > specified max
- Error messages should list valid directive identifiers

---

## Dependencies

- NPL expression parser (FR-1)
- Section resolver (FR-2)
- Priority filter (FR-3)
- `npl/directives.yaml` file with component definitions

---

## Test Coverage Requirements

- Unit tests for directive-specific parsing
- Integration tests for full loading workflow
- Edge cases: invalid names, missing directives, priority boundaries
- Target coverage: 80%+ for new code paths
