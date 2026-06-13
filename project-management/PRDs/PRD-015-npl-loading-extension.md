# PRD-015: NPL Advanced Loading Extension

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

---

## Overview

Extend the NPL loading mechanism beyond the current syntax section to support all NPL sections: directives, fences, pumps, formatting, prefixes, special-sections, and declarations. This enables users and agents to load specific NPL components using expressive query syntax with priority filtering, cross-section combinations, and flexible layout strategies.

### Goals

1. Enable loading of any NPL section using consistent expression syntax
2. Support priority filtering across all sections
3. Enable cross-section expressions with additions and subtractions
4. Maintain backward compatibility with existing syntax section loading
5. Achieve 80%+ test coverage for all new code

### Non-Goals

- Modifying the underlying YAML schema of NPL sections
- Creating new layout strategies (use existing: yaml-order, classic, grouped)
- Building a full NPL parser (covered by PRD-013)

---

## User Stories

User stories for this PRD are defined in separate files for clarity and reusability:

| ID | Title | File | Priority | Status |
|---|---|---|---|---|
| US-201 | Load Directives Section with Priority Filtering | `project-management/user-stories/US-201-load-directives-section.md` | High | draft |
| US-202 | Load Fences Section with All Layout Strategies | `project-management/user-stories/US-202-load-fences-section.md` | High | draft |
| US-203 | Load Pumps Section with Complex Expressions | `project-management/user-stories/US-203-load-pumps-section.md` | Medium | draft |
| US-204 | Cross-Section Loading with Additions and Subtractions | `project-management/user-stories/US-204-cross-section-loading.md` | Medium | draft |
| US-205 | Generate Coverage Reports for All Loaded Components | `project-management/user-stories/US-205-generate-coverage-reports.md` | High | draft |

**To load a user story**: Use the MCP tool `get-story {story-id}`

```bash
# Example: Load a specific story
get-story US-201

# Then edit if needed:
edit-story US-201 title "Updated Title"
```

---

## Functional Requirements

Functional requirements are defined in separate files for modularity and versioning:

### FR Registry

See `project-management/PRDs/PRD-015-npl-loading-extension/functional-requirements/index.yaml` for complete list.

| ID | Title | File |
|---|---|---|
| FR-1 | Expression Parser Extension | `functional-requirements/FR-1.md` |
| FR-2 | Section Resolver | `functional-requirements/FR-2.md` |
| FR-3 | Priority Filter | `functional-requirements/FR-3.md` |
| FR-4 | Layout Strategies | `functional-requirements/FR-4.md` |
| FR-5 | Unified Loading API | `functional-requirements/FR-5.md` |

**To load a functional requirement**: Use the file path or MCP tools:

```bash
# Load specific FR
view_markdown project-management/PRDs/PRD-015-npl-loading-extension/functional-requirements/FR-1.md

# Filter to specific section
view_markdown project-management/PRDs/PRD-015-npl-loading-extension/functional-requirements/FR-1.md \
  --filter "Interface"
```

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage for new code | Line coverage | >= 80% |
| NFR-2 | Critical path coverage | Branch coverage | 100% |
| NFR-3 | Parse expression performance | Time | < 10ms |
| NFR-4 | Resolve expression performance | Time | < 100ms for full section |
| NFR-5 | Backward compatibility | Existing tests | All pass |
| NFR-6 | Error message quality | Contains context | Always |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Empty expression | NPLParseError | "Expression cannot be empty" |
| Unknown section | NPLParseError | "Unknown section: '{section}'. Valid sections: syntax, directives, pumps, ..." |
| Unknown component | NPLResolveError | "Component '{component}' not found in section '{section}'" |
| Invalid priority | NPLParseError | "Invalid priority format: '{value}'. Use :+N where N is a number" |
| Missing YAML file | NPLResolveError | "Section file not found: {path}" |
| YAML parse error | NPLResolveError | "Invalid YAML in {file}: {details}" |
| Subtraction of non-loaded | NPLResolveError | "Cannot subtract '{component}' - not in loaded set" |

---

## Acceptance Tests

Acceptance tests are defined in separate files for easier test suite generation:

### AT Registry

See `project-management/PRDs/PRD-015-npl-loading-extension/acceptance-tests/index.yaml` for complete list.

| ID | Title | File |
|---|---|---|
| AT-1 | Section Loading Tests | `acceptance-tests/AT-1.md` |
| AT-2 | Component Loading Tests | `acceptance-tests/AT-2.md` |
| AT-3 | Priority Filtering Tests | `acceptance-tests/AT-3.md` |
| AT-4 | Cross-Section Expression Tests | `acceptance-tests/AT-4.md` |
| AT-5 | Layout Strategy Tests | `acceptance-tests/AT-5.md` |
| AT-6 | Error Handling Tests | `acceptance-tests/AT-6.md` |
| AT-7 | Integration Tests | `acceptance-tests/AT-7.md` |

**To generate test suite**: Pass this PRD to `npl-tdd-tester` agent

```bash
# TDD Workflow:
1. npl-idea-to-spec → Creates personas + user stories
2. npl-prd-editor → Creates this PRD (you are here)
3. npl-tdd-tester → Reads acceptance-tests/ to generate test_*.py
4. npl-tdd-coder → Implements code to pass tests
5. npl-tdd-debugger → Fixes any test failures
```

---

## Success Criteria

1. **All 5 user stories fully implemented** with all acceptance criteria passing
2. **Test coverage >= 80%** for all new code (measured by `mise run test-coverage`)
3. **Critical paths have 100% coverage**: parser, resolver, priority filter
4. **All existing tests still pass** (no regressions)
5. **Cross-section expressions work correctly** for all combinations
6. **Error messages are clear and actionable** with context
7. **Performance meets targets**: parse < 10ms, resolve < 100ms

---

## Implementation Notes

### Directory Structure

```
src/npl_mcp/npl/
    __init__.py
    parser.py          # Expression parser (FR-1)
    resolver.py        # Section resolver (FR-2)
    filters.py         # Priority filter (FR-3)
    layout.py          # Layout strategies (FR-4)
    loader.py          # Unified API (FR-5)
    exceptions.py      # Custom exceptions

tests/npl/
    test_parser.py
    test_resolver.py
    test_filters.py
    test_layout.py
    test_loader.py
    test_integration.py
```

### Expression Grammar

```
expression      := term (WS term)*
term            := addition | subtraction
addition        := section_ref
subtraction     := '-' section_ref
section_ref     := section ('#' component)? (':' priority)?
section         := 'syntax' | 'directives' | 'pumps' | 'prefixes' |
                   'special-sections' | 'declarations' | 'prompt-sections' | 'fences'
component       := SLUG
priority        := '+' NUMBER
SLUG            := [a-z][a-z0-9-]*
NUMBER          := [0-9]+
WS              := ' '+
```

### NPL Section Files

| Section | File | Components Field |
|---------|------|------------------|
| syntax | syntax.yaml | components |
| directives | directives.yaml | components |
| pumps | pumps.yaml | components |
| prefixes | prefixes.yaml | components |
| special-sections | special-sections.yaml | components |
| declarations | declarations.yaml | components |
| prompt-sections | prompt-sections.yaml | components |
| fences | fences.yaml | components (if exists) |

---

## Out of Scope

- Creating new NPL sections (schema changes)
- Building visual UI for expression building
- Real-time validation/autocomplete
- NPL syntax parsing/AST (see PRD-013)
- MCP tool integration (future PRD)

---

## Dependencies

- Existing NPL YAML files in `npl/` directory
- PyYAML for YAML parsing
- pytest for testing
- pytest-cov for coverage reporting

---

## Open Questions

- [ ] Q1: Should `fences` section be created if it doesn't exist?
- [ ] Q2: Should `include_instructional` flag be supported for sections that have instructional content?
- [ ] Q3: Should we support regex patterns in component selection (e.g., `syntax#*fill*`)?

---

## References

- User Stories: `project-management/user-stories/US-20{1-5}-*.md`
- Functional Requirements: `project-management/PRDs/PRD-015-npl-loading-extension/functional-requirements/`
- Acceptance Tests: `project-management/PRDs/PRD-015-npl-loading-extension/acceptance-tests/`
- Architecture: `/docs/PROJ-ARCH.md`
- NPL Syntax YAML: `/npl/syntax.yaml`
- NPL Directives YAML: `/npl/directives.yaml`
- NPL Pumps YAML: `/npl/pumps.yaml`
- Related PRD: `PRD-013-npl-syntax-parser.md`

---

## How to Use This PRD

### For TDD Agent Workflow

1. **Phase 1 - Specification** ✅
   - User stories extracted to `project-management/user-stories/`
   - Each story references this PRD

2. **Phase 2 - Test Generation**
   - Run: `npl-tdd-tester --prd project-management/PRDs/PRD-015-npl-loading-extension.md`
   - Agent reads acceptance tests from `acceptance-tests/` directory
   - Generates: `tests/test_npl_loading.py` with full test suite

3. **Phase 3 - Implementation**
   - Run: `npl-tdd-coder --prd project-management/PRDs/PRD-015-npl-loading-extension.md`
   - Coder reads FRs from `functional-requirements/` directory
   - Implements code matching FRs and passing acceptance tests

4. **Phase 4 - Validation**
   - All tests pass: `mise run test-status`
   - Coverage >= 80%: `mise run test-coverage`
   - PRD requirements satisfied

### For Manual Implementation

- Reference the individual FR files for detailed specifications
- Use acceptance test files as test plan
- Follow the directory structure suggested in Implementation Notes

---

**Last Updated**: 2026-02-02
**PRD Status**: Ready for Test Suite Generation
