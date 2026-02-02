# User Story: Build NPL Syntax Pattern Library (155 elements)

**ID**: US-087
**Persona**: P-005 (Language Specialist)
**Priority**: Medium
**Status**: Draft
**PRD Group**: npl_language
**Created**: 2026-02-02

## As a...
Language Specialist maintaining the NPL specification

## I want to...
Catalog all 155 NPL syntax elements as documented patterns with examples and usage guidelines

## So that...
Developers and agents can reference, learn, and apply NPL patterns consistently

## Acceptance Criteria
- [ ] Document all 155 NPL syntax elements with type, syntax, semantics, and constraints
- [ ] Provide 2-3 runnable examples for each element category (directives, references, etc.)
- [ ] Create pattern index with tagging (basic, advanced, nested, conditional)
- [ ] Generate cheat sheet with common pattern combinations
- [ ] Include anti-patterns and common mistakes for each category
- [ ] Provide migration guide for NPL versions and syntax changes
- [ ] All patterns validated against parser for correctness

## Implementation Notes
**Gap**: Comprehensive pattern library documentation, example generation, validation
**Documented in**: `.tmp/docs/NPL-SYNTAX.md` (partial) and scattered prompt files
**Current state**: Syntax elements identified; library not fully documented
**Legacy source**: Patterns compiled from multiple sub-agent prompt files

## Related Stories
- **Related**: US-080, US-084, US-090
- **PRD**: prd-010-npl-language-tooling
- **Personas**: P-005

## Notes
Pattern library is marketing and learning material. Should be auto-generated where possible and published as interactive guide.
