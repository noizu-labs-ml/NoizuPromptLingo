# US-204: Cross-Section Loading with Additions and Subtractions

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-204 |
| **Title** | Cross-Section Loading with Additions and Subtractions |
| **Priority** | Medium |
| **Story Points** | 4 |
| **Status** | Draft |
| **Related Personas** | P-003 (Vibe Coder) |
| **Related PRD** | PRD-012: NPL Advanced Loading Extension |

---

## Description

As a system builder, I want to load across multiple sections with complex expressions like `syntax directive -syntax#literal-string`.

This enables building custom NPL contexts by mixing and matching components from different sections while excluding unwanted elements, providing maximum flexibility for tailored prompt configurations.

---

## Acceptance Criteria

- [ ] **AC-4.1**: Can mix sections using expression: `syntax directive`
- [ ] **AC-4.2**: Can subtract from sections using expression: `syntax -syntax#literal-string`
- [ ] **AC-4.3**: Can mix specific and section loads: `syntax#placeholder pumps#intent-declaration`
- [ ] **AC-4.4**: All validation works correctly for:
  - Invalid section names
  - Invalid component names
  - Malformed expressions
- [ ] **AC-4.5**: Clear error messages for invalid expressions with helpful context
- [ ] **AC-4.6**: Order of operations is correct: load full sections first, then apply additions, then subtractions

---

## Technical Notes

- Parser must handle space-separated section/component references
- Parser must distinguish between addition and subtraction operators
- Resolver must maintain order of operations:
  1. Load full sections (e.g., `syntax directive`)
  2. Add specific components (e.g., `+syntax#placeholder`)
  3. Subtract components (e.g., `-syntax#literal-string`)
- Subtracting a non-loaded component should warn but not error
- Error messages must include expression context and suggestions

---

## Dependencies

- NPL expression parser with cross-section support (FR-1)
- Section resolver with operation ordering (FR-2)
- All NPL section YAML files

---

## Test Coverage Requirements

- Unit tests for cross-section expression parsing
- Integration tests for operation ordering
- Edge cases: empty sections, subtraction of non-existent components
- Error handling tests with validation of error messages
- Target coverage: 80%+ for cross-section logic

---

## Examples

```
# Mix two sections
syntax directive

# Load section, exclude component
syntax -syntax#literal-string

# Mix specific components from different sections
syntax#placeholder pumps#intent-declaration

# Complex cross-section expression
syntax directive#table-formatting:+1 -syntax#omission

# Multiple subtractions
syntax pumps -syntax#literal-string -pumps#tangential-exploration
```

---

## Error Handling Examples

| Expression | Error | Message |
|------------|-------|---------|
| `syntax foobar` | NPLParseError | "Unknown section: 'foobar'. Valid sections: syntax, directives, pumps, ..." |
| `syntax#nonexistent` | NPLResolveError | "Component 'nonexistent' not found in section 'syntax'" |
| `syntax#placeholder:-1` | NPLParseError | "Invalid priority format: '-1'. Use :+N where N >= 0" |
| ` ` (empty) | NPLParseError | "Expression cannot be empty" |
