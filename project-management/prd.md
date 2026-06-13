# PRD Format Specification

This document defines the structure and format of Product Requirement Documents (PRDs) used in the NoizuPromptLingo project.

## Overview

PRDs are created and managed by the `prd-editor` agent based on user stories defined by the `idea-to-spec` agent. They serve as the authoritative specification for the TDD (Test-Driven Development) workflow, providing detailed requirements that guide both test creation and implementation.

## Purpose

PRDs (Product Requirement Documents) transform user stories into actionable specifications that guide test-driven development. They serve as the bridge between high-level feature requests and concrete implementation.

PRDs ensure:
- **Unambiguous requirements** for implementation by the `tdd-coder` agent
- **Clear acceptance criteria** for test creation by the `tdd-tester` agent
- **Defined scope boundaries** to prevent feature creep
- **Traceability** from implementation back to user needs

## File Location

PRDs are stored in the `docs/PRDs/` directory structure. The location depends on the project context:

**Main NPL Framework** (extended workspace):
```
worktrees/main/.npl/prds/
├── PRD-001.md
├── PRD-002.md
└── ...
```

**Root Project** (if docs/PRDs/ directory exists):
```
docs/PRDs/
├── PRD-001.md
├── PRD-002.md
└── ...
```

The `prd-editor` agent determines the appropriate location based on project structure.

## Naming Convention

PRD files follow the pattern: `PRD-XXX.md` where `XXX` is a zero-padded 3-digit number (e.g., `PRD-001.md`, `PRD-042.md`).

Alternative naming with descriptive slugs is also supported: `feature-name.prd.md` (e.g., `mcp-persona-test.prd.md`).

## PRD Structure Template

```markdown
# [Feature Title] PRD

**ID**: PRD-XXX
**Title**: [Feature Title]
**Priority**: critical|high|medium|low
**Status**: draft|approved|in_progress|completed|blocked
**Created**: [YYYY-MM-DD]
**Updated**: [YYYY-MM-DD]

## Related User Stories

- [US-XXX] [Story Title] ([user-stories/US-XXX-title.md](../docs/user-stories/US-XXX-title.md))
- ...

## Related Personas

- [P-XXX] [Persona Name] ([../docs/personas/persona-file.md](../docs/personas/persona-file.md))
- ...

## Overview

[2-4 paragraph description of what this PRD specifies. Explain the feature
from a technical perspective, focusing on what needs to be built rather than
why it's needed (that's covered in the user story).]

## Scope

### In Scope

- [Specific capability A]
- [Specific capability B]
- ...

### Out of Scope

- [Related capability C not included in this iteration]
- [Future enhancement D]
- ...

## Functional Requirements

### FR-001: [Requirement Title]

**Description**: [Clear, unambiguous statement of required behavior]

**Acceptance Criteria**:
- [ ] [Specific testable condition]
- [ ] [Specific testable condition]
- ...

**Dependencies**: [Other requirements or system components]

**Notes**: [Additional context]

[Repeat for each functional requirement]

## Non-Functional Requirements

### NFR-001: [NFR Title]

**Type**: performance|security|reliability|usability|maintainability

**Requirement**: [Measurable criteria]

**Success Metric**: [How to verify this requirement]

[Repeat as needed]

## API / Interface Specification

### [Endpoint/Function Name]

**Purpose**: [What this API/function does]

**Signature**:
```python
def function_name(param1: type1, param2: type2) -> ReturnType:
    """
    [Brief description]
    """
```

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| param1 | Type | Yes | [Description] |
| param2 | Type | No | [Description] |

**Returns**: `ReturnType` - [Description]

**Raises**:
| Exception | Condition |
|-----------|-----------|
| ErrorType | [When raised] |

**Example**:
```python
result = function_name(value1, value2)
# result: [expected value]
```

[Repeat for each API/function]

## Data Structures

### [Structure Name]

**Purpose**: [What this structure represents]

**Fields**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| field1 | Type | Yes | [Description] |
| field2 | Type | No | [Description] |

**Schema** (if applicable):
```yaml
field1: type
field2:
  nested_field: type
```

[Repeat as needed]

## Success Criteria

The feature is considered complete when:

1. [Measurable outcome A]
2. [Measurable outcome B]
3. ...

## Testing Strategy

### Unit Tests

- [Component X] - Test cases for [specific scenarios]
- [Component Y] - Test cases for [specific scenarios]

### Integration Tests

- [Integration point A] - Test cases for [specific scenarios]
- [Integration point B] - Test cases for [specific scenarios]

### User Acceptance Tests

Based on user story acceptance criteria:
- [ ] [Original acceptance criterion from US-XXX]
- ...

## Dependencies

### External Dependencies

- [Dependency Name] - [Version] - [Purpose]

### Internal Dependencies

- [Other PRD-YYY] - [Required functionality]
- [Existing component Z] - [Required functionality]

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk description] | High/Med/Low | High/Med/Low | [Mitigation strategy] |

## Open Questions

| Question | Owner | Due Date |
|----------|--------|----------|
| [Unresolved issue] | [ who owns] | [Date] |
```

## Section Guidelines

### Overview

- 2-4 paragraphs maximum
- Focus on WHAT, not WHY
- Technical perspective
- Reference the user story for motivation

### Functional Requirements

- Each requirement must be testable
- Use unique IDs (FR-001, FR-002, etc.)
- Include clear acceptance criteria
- One requirement per FR section

### Non-Functional Requirements

- Must be measurable
- Include success metrics
- Common types: performance, security, reliability, usability, maintainability

### API / Interface Specification

- Include function signatures
- Document all parameters (name, type, required/optional, description)
- Document return types
- Document exceptions/errors
- Provide usage examples

### Data Structures

- Define all custom types/schemas
- Document field requirements
- Provide example representations

### Success Criteria

- Measurable outcomes
- Align with user story acceptance criteria
- Specific enough to determine completion

## Traceability

PRDs maintain end-to-end traceability in the TDD workflow:

1. **User Story References**: Every PRD links to its source user stories (US-XXX files in `docs/user-stories/`)
2. **Persona References**: Every PRD links to relevant personas (P-XXX files in `docs/personas/`)
3. **Requirement IDs**: Unique functional requirement IDs (FR-001, FR-002, etc.) enable tracking from PRD → tests → implementation
4. **Cross-References**: Links between related PRDs show dependencies

**Traceability Flow**:
```
Persona (P-XXX) → User Story (US-XXX) → PRD (PRD-XXX/FR-001) → Test (test_feature.py) → Code (src/)
```

## Workflow

PRDs flow through the multi-agent TDD system:

1. **Creation**: `prd-editor` agent generates PRD from approved user stories
2. **Review**: Validate PRD completeness and accuracy against quality checklist
3. **Approval**: Update status to `approved` when ready for implementation
4. **Test Generation**: `tdd-tester` agent creates test suite based on PRD requirements
5. **Implementation**: `tdd-coder` agent implements features to pass tests
6. **Debug Loop**: `tdd-debugger` identifies issues and may request PRD clarification
7. **Updates**: PRDs are revised during implementation if gaps or ambiguities are discovered
8. **Completion**: Update status to `completed` when all acceptance criteria are met

**Status Progression**: `draft` → `approved` → `in_progress` → `completed` (or `blocked` if issues arise)

## Quality Checklist

Before marking a PRD as `approved`, verify:

**Traceability**:
- [ ] All source user stories are linked (with correct paths to `docs/user-stories/US-XXX-*.md`)
- [ ] All relevant personas are referenced (with correct paths to `docs/personas/*.md`)

**Requirements**:
- [ ] All functional requirements (FR-XXX) are testable and unambiguous
- [ ] All non-functional requirements (NFR-XXX) have measurable success metrics
- [ ] Requirements have unique IDs for tracking

**Specifications**:
- [ ] API/interface specifications are complete with signatures, parameters, and return types
- [ ] Data structures are fully defined with field types and constraints
- [ ] Edge cases and error conditions are documented

**Completeness**:
- [ ] Success criteria are established and measurable
- [ ] Dependencies (internal and external) are identified
- [ ] Testing strategy covers unit, integration, and acceptance tests
- [ ] No open critical questions remain

**Agent Readiness**:
- [ ] Sufficient detail for `tdd-tester` to create comprehensive test suite
- [ ] Clear enough for `tdd-coder` to implement autonomously

## Examples

For reference PRD implementations, see:
- `worktrees/main/.npl/prds/*.prd.md` - Example PRDs from the main NPL framework

## Related Documents

- [docs/prd.summary.md](prd.summary.md) - High-level overview of PRDs
- [docs/user-stories.md](user-stories.md) - User story documentation
- [docs/personas/](personas/) - Persona definitions
- [agents/prd-editor.md](../../agents/prd-editor.md) - Agent responsible for PRD creation
- [docs/PROJ-LAYOUT.md](PROJ-LAYOUT.md) - Project structure and file locations
- [docs/arch/agent-orchestration.md](arch/agent-orchestration.md) - Complete agent workflow including PRD role