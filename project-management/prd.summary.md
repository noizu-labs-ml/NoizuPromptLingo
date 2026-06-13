# PRD Summary

PRD (Product Requirement Document) files are detailed technical specifications that transform user stories into actionable implementation requirements with testable acceptance criteria.

## Purpose

PRDs bridge the gap between high-level user stories and concrete implementation. They translate "what users want" into "what the system must do" with unambiguous, testable specifications that enable test-driven development.

## Relationship to Other Artifacts

```
Feature Idea (idea-to-spec agent)
    ↓
docs/personas/ (P-XXX persona definitions)
    ↓
docs/user-stories/ (US-XXX user stories)
    ↓
docs/PRDs/ or worktrees/main/.npl/prds/ (PRD-XXX specifications)
    ↓
tests/ (tdd-tester creates test suite)
    ↓
src/ (tdd-coder implements features)
```

## PRD Structure

Each PRD (e.g., `PRD-001.md`) contains:

| Section | Content |
|---------|---------|
| Metadata | ID, title, priority, status, related stories, personas |
| Overview | Brief technical description of the feature |
| Scope | What's included and explicitly excluded |
| Functional Requirements | Testable behavioral specifications with IDs (FR-XXX) |
| Non-Functional Requirements | Measurable performance, security, reliability criteria |
| API/Interface Specification | Function signatures, parameters, return types, exceptions |
| Data Structures | Custom types, schemas, field definitions |
| Success Criteria | Measurable outcomes for completion |
| Testing Strategy | Unit, integration, and acceptance test plans |
| Dependencies | External packages and internal component requirements |

## Personas Used in PRDs

| ID | Persona | Primary Focus |
|----|---------|---------------|
| P-001 | AI Agent | Automation, scriptable features |
| P-002 | Product Manager | Dashboards, review workflows |
| P-003 | Vibe Coder | Developer tools, rapid prototyping |
| P-004 | Project Manager | Agent coordination, tracking |
| P-005 | Dave | Code review, quality assurance |

## Workflow Participation

PRDs are managed by the `prd-editor` agent:
1. **Creation**: Generates PRDs from approved user stories in `docs/user-stories/`
2. **Traceability**: Links user stories, personas, and requirements with unique IDs
3. **Specification**: Provides testable requirements for `tdd-tester` agent
4. **Updates**: Revises PRDs when implementation gaps are discovered
5. **Completion**: Marks status as `completed` when all acceptance criteria are met

## Key Elements

**Traceability**: Every PRD maintains links to user stories, personas, and requirement IDs that flow through to tests and code.

**Quality Gates**: PRDs require approval checklist completion before implementation:
- All user stories and personas linked
- Functional requirements testable
- Non-functional requirements measurable
- API specifications complete
- Success criteria established

## Files and Locations

**PRD Storage** (location depends on project structure):
- `worktrees/main/.npl/prds/` - PRDs in the main NPL framework (extended workspace)
- `docs/PRDs/` - PRDs in root project (alternative location if directory exists)

**Naming Patterns**:
- Numbered: `PRD-XXX.md` (e.g., `PRD-001.md`, `PRD-042.md`)
- Descriptive: `feature-name.prd.md` (e.g., `mcp-persona-test.prd.md`)

**Related Documentation**:
- `docs/prd.md` - PRD format specification (template and guidelines for `prd-editor` agent)
- `docs/prd.summary.md` - This overview document
- `docs/user-stories/US-XXX-*.md` - Source user stories referenced by PRDs
- `docs/personas/*.md` - Persona definitions (P-XXX) referenced in PRDs
- `agents/prd-editor.md` - Agent responsible for creating and updating PRDs