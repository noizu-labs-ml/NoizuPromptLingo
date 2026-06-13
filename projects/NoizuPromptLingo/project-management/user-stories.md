# User Stories

User stories define the features and capabilities of the NPL MCP server from the perspective of different personas. They serve as the foundation for creating PRD documents and guiding the test-driven development (TDD) workflow.

## Purpose

User stories capture what users (personas) need from the system and why. Each story follows the standard format:

> As a **[persona]**,
> I want to **[action/capability]**,
> So that **[benefit/outcome]**.

## Structure

Each user story file (e.g., `US-001-load-npl-core.md`) contains:

- **ID**: Unique identifier (US-001 through US-037)
- **Persona**: Associated persona ID (P-001 through P-005)
- **Priority**: critical, high, medium, or low
- **Status**: draft, in_progress, done, or blocked
- **Story**: The standard user story format
- **Acceptance Criteria**: Checklist of conditions for implementation
- **Notes**: Additional context or constraints
- **Dependencies**: Other stories or prerequisites
- **Open Questions**: Items needing clarification
- **Related Commands**: Associated MCP tools or commands

## Organization

Stories are organized into 7 PRD priority groups (mapped to `prd_group` in index.yaml):

| Group | prd_group | Description | Count |
|-------|-----------|-------------|-------|
| NPL Load | npl_load | Loading prompt conventions and NPL components | 4 |
| Chat/Collaboration | chat | Real-time messaging and collaboration | 7 |
| Artifacts/Reviews | artifacts | Versioned artifacts and review workflows | 5 |
| Task Queue | tasks | Task management and queue operations | 7 |
| Browser/Screenshots | browser | Browser automation and visual testing | 7 |
| Agent Coordination | coordination | Monitoring and coordinating AI agents | 3 |
| Human-Agent Collaboration | collaboration | Developer-AI pair programming | 4 |

## Personas

| ID | Name | Description |
|----|------|-------------|
| P-001 | AI Agent | Autonomous, programmatic automation agent |
| P-002 | Product Manager | Non-technical reviewer needing dashboards |
| P-003 | Vibe Coder | Developer focused on rapid prototyping |
| P-004 | Project Manager | Coordinates agents, sprint planning, task tracking |
| P-005 | Dave the Fellow Developer | Senior developer focusing on code review and quality |

## Index

The [`user-stories/index.yaml`](user-stories/index.yaml) file is managed by the `idea-to-spec` agent and contains:
- Story metadata (ID, title, file, persona, priority, status)
- PRD group assignments
- Collaborator references

## Workflow

User stories are created by the `idea-to-spec` agent and feed into:
1. **prd-editor** - Generates detailed specifications
2. **tdd-tester** - Creates test suites based on acceptance criteria
3. **tdd-coder** - Implements features using test-driven development
4. **tdd-debugger** - Resolves issues in implementation

For detailed information about available stories, see [user-stories.summary.md](user-stories.summary.md) or [layout/user-stories.md](layout/user-stories.md).