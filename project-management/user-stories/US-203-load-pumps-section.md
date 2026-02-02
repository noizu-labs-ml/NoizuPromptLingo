# US-203: Load Pumps Section with Complex Expressions

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-203 |
| **Title** | Load Pumps Section with Complex Expressions |
| **Priority** | Medium |
| **Story Points** | 5 |
| **Status** | Draft |
| **Related Personas** | P-001 (AI Agent), Prompt Engineer |
| **Related PRD** | PRD-012: NPL Advanced Loading Extension |

---

## Description

As a prompt engineer, I want to load reasoning pumps with expressions like `pumps#intent-declaration:+2+pumps#critical-analysis:+1`.

This enables precise control over which reasoning pumps are loaded and at what priority level, allowing custom prompt configurations for different reasoning tasks.

---

## Acceptance Criteria

- [ ] **AC-3.1**: Can load all pumps using expression `pumps`
- [ ] **AC-3.2**: Can load specific pump using expression `pumps#chain-of-thought`
- [ ] **AC-3.3**: Can combine multiple pumps with `+` operator: `pumps#intent-declaration+chain-of-thought`
- [ ] **AC-3.4**: Can subtract pumps using `-` operator: `pumps -pumps#tangential-exploration`
- [ ] **AC-3.5**: Priority filtering works correctly with expression `pumps#self-assessment:+1`
- [ ] **AC-3.6**: Pump identifiers match slugs:
  - `intent-declaration`
  - `chain-of-thought`
  - `self-assessment`
  - `tangential-exploration`
  - `critical-analysis`
  - `evaluation-framework`
  - `emotional-context`

---

## Technical Notes

- Parser must support `+` operator for additions within same section
- Parser must support `-` operator for subtractions
- Resolver must handle multiple component references in single expression
- Priority filter applies to each component independently
- Order of operations: load all additions first, then apply subtractions

---

## Dependencies

- NPL expression parser with operator support (FR-1)
- Section resolver with multi-component support (FR-2)
- Priority filter (FR-3)
- `npl/pumps.yaml` file with component definitions

---

## Test Coverage Requirements

- Unit tests for complex expression parsing
- Integration tests for pump combinations
- Edge cases: subtraction of non-loaded pumps, conflicting priorities
- Target coverage: 80%+ for parser operator handling

---

## Examples

```
# Load all pumps
pumps

# Load specific pump
pumps#chain-of-thought

# Load multiple pumps
pumps#intent-declaration+chain-of-thought

# Load with priority filter
pumps#self-assessment:+1

# Load section, exclude specific pump
pumps -pumps#tangential-exploration

# Complex combination
pumps#intent-declaration:+2+pumps#critical-analysis:+1
```
