# Task: Rename and Document Agent prd-editor → npl-prd-editor

## Overview
Rename the prd-editor agent to use "npl-" prefix and create corresponding documentation. This agent transforms user stories and feature requests into well-structured PRD documents that drive TDD test generation and implementation.

## Your Responsibilities
1. Rename agent file: `agents/prd-editor.md` → `agents/npl-prd-editor.md`
2. Update internal fields:
   - `name:` from "prd-editor" to "npl-prd-editor"
   - `agent_id:` from "prd-editor" to "npl-prd-editor"
3. Create persona documentation: `docs/personas/agents/npl-prd-editor.md`
4. Update all references in assigned documentation files

## Agent File Content

```yaml
---
name: prd-editor
description: Transforms user stories and feature requests into well-structured PRD documents under .prd/. Creates specifications precise enough for TDD test generation and autonomous implementation. Updates PRDs based on feedback from implementation cycle.
model: claude
color: purple
---

# PRD Editor Agent

## Identity

```yaml
agent_id: prd-editor
role: PRD Author and Specification Specialist
lifecycle: long-lived
reports_to: controller
```

[Full content includes: Purpose, Interface, Commands, Response Format, Behavior, Lifecycle, Interaction Patterns, Output Artifacts, PRD Template, Naming Convention, Constraints]
```

## New Name
`npl-prd-editor`

## Old Name (for search/replace)
`prd-editor`

## Documentation Files to Update
- `CLAUDE.md` - TDD Agent Workflow section references agent name
- `docs/arch/agent-orchestration.summary.md` - Agent pipeline descriptions
- `.prd/` directory documentation (if any)
- Any specification templates referencing this agent

## Persona Documentation

Create `docs/personas/agents/npl-prd-editor.md` following this structure:

```markdown
# Agent Persona: PRD Editor Specialist

**Agent ID**: npl-prd-editor
**Type**: Specification & Documentation
**Version**: 1.0.0

## Overview
Transforms feature requests, user stories, and change descriptions into well-structured PRD documents. Creates specifications precise enough to drive TDD Tester test generation and TDD Coder autonomous implementation.

## Role & Responsibilities
- Parses feature descriptions and loads referenced user stories
- Analyzes personas and architectural constraints
- Selects and applies appropriate PRD templates
- Maps user stories to functional requirements
- Writes testable, unambiguous specifications
- Defines interfaces with type information
- Specifies error handling and edge cases
- Documents non-functional requirements
- Validates completeness before handoff
- Updates PRDs based on implementation feedback

## Strengths
✅ Precise, testable requirement generation
✅ Clear interface and type specifications
✅ Comprehensive error handling documentation
✅ Quality validation before handoff
✅ Effective communication with downstream agents (TDD Tester, TDD Coder)

## Needs to Work Effectively
- Access to `docs/personas/` for context
- Access to `docs/user-stories/` directory
- Project architecture documentation (`PROJ-ARCH.md`)
- Existing PRDs for reference and consistency
- Controller availability for ambiguity resolution

## Typical Workflows
1. **PRD Creation**: Parse feature spec → load stories/personas → select template → write requirements → validate → handoff
2. **PRD Refinement**: Receive feedback from TDD Coder → update problem areas → validate → return
3. **Quality Review**: Check completeness → verify testability → ensure consistency → confirm readiness

## Integration Points
- **Receives from**: Idea to Spec (story IDs), Controller (feature descriptions, implementation feedback)
- **Feeds to**: TDD Tester (specification for test generation)
- **Coordinates with**: Controller (clarifications, updates), TDD Coder (issue resolution)
- **References**: User stories, personas, architecture documents

## Success Metrics
- All requirements are testable (can be verified by tests)
- No ambiguities in specification (single interpretation)
- Complete coverage of acceptance criteria
- Clear scope boundaries (explicit out-of-scope items)
- Traceability back to user stories and personas

## Validation Checklist
- [ ] Agent file renamed to `agents/npl-prd-editor.md`
- [ ] `name:` field updated to "npl-prd-editor"
- [ ] `agent_id:` field updated to "npl-prd-editor"
- [ ] Persona documentation created at `docs/personas/agents/npl-prd-editor.md`
- [ ] CLAUDE.md agent references updated
- [ ] docs/arch/agent-orchestration.summary.md references updated
- [ ] .prd/ documentation cross-references checked
- [ ] All specification templates reference correct agent name
- [ ] No broken references remain in codebase
```

---

**Notes**:
- This agent focuses on specification quality and testability
- Emphasize the bridge role between discovery and implementation
- Preserve all PRD template examples and quality criteria
- Include the naming convention for PRD files in context
