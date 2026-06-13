# User Stories Layout

The `docs/user-stories/` directory contains 37 user stories organized by PRD priority groups. Each story follows the pattern `US-XXX-title.md`.

## Purpose

User stories capture requirements from specific persona perspectives, providing:
- Clear acceptance criteria for feature implementation
- Persona-driven context for understanding needs
- Dependencies and relationships between features
- Guidance for the TDD workflow (test creation before coding)

## Directory Structure

```
docs/user-stories/
├── index.yaml                  # Managed by idea-to-spec agent via yq
├── US-001-load-npl-core.md
├── US-002-load-project-context.md
├── US-003-fetch-web-as-markdown.md
├── US-004-share-artifact-chat.md
├── US-005-view-session-dashboard.md
├── US-006-send-message-to-room.md
├── US-007-create-chat-room.md
├── US-008-create-versioned-artifact.md
├── US-009-review-artifact-history.md
├── US-010-add-inline-comment.md
├── US-011-annotate-screenshot.md
├── US-012-capture-screenshot.md
├── US-013-compare-screenshots.md
├── US-014-pick-task-from-queue.md
├── US-015-view-task-progress.md
├── US-016-create-task.md
├── US-017-link-artifact-to-task.md
├── US-018-update-task-status.md
├── US-019-automate-form-submission.md
├── US-020-quick-form-fill.md
├── US-021-browser-navigation.md
├── US-022-receive-notifications.md
├── US-023-complete-review.md
├── US-024-manage-browser-state.md
├── US-025-explore-project-structure.md
├── US-026-ask-question-on-task.md
├── US-027-react-to-message.md
├── US-028-create-chat-todo.md
├── US-029-inject-page-scripts.md
├── US-030-assign-task-complexity.md
├── US-031-view-agent-work-logs.md
├── US-032-assign-tasks-to-agents.md
├── US-033-monitor-sprint-progress.md
├── US-034-review-agent-generated-code.md
├── US-035-share-context-with-agents.md
├── US-036-pair-program-via-chat.md
└── US-037-track-code-quality-metrics.md
```

## Organization by PRD Priority Groups

### Group 1: NPL Load (Priority: Critical, prd_group: npl_load)
Stories for loading prompt conventions and NPL components.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-001 | Load NPL Core Components | P-001 | critical | draft |
| US-002 | Load Project-Specific Context | P-001 | critical | draft |
| US-003 | Fetch Web Content as Markdown | P-003 | high | draft |
| US-025 | Explore Project File Structure | P-001 | medium | draft |

### Group 2: Chat/Collaboration (Priority: High, prd_group: chat)
Stories for real-time messaging and collaboration features.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-004 | Share Artifact in Chat Room | P-003 | high | draft |
| US-005 | View Session Dashboard | P-002 | high | draft |
| US-006 | Send Message to Chat Room | P-003 | high | draft |
| US-007 | Create Chat Room for Collaboration | P-001 | high | draft |
| US-022 | Receive and Manage Notifications | P-002 | medium | draft |
| US-027 | React to Chat Messages | P-003 | low | draft |
| US-028 | Create Todo from Chat | P-003 | low | draft |

### Group 3: Artifacts/Reviews (Priority: High, prd_group: artifacts)
Stories for versioned artifacts and collaborative review workflows.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-008 | Create Versioned Artifact | P-001 | high | draft |
| US-009 | Review Artifact Revision History | P-002 | medium | draft |
| US-010 | Add Inline Review Comment | P-002 | medium | draft |
| US-011 | Annotate Screenshot with Overlay | P-002 | medium | draft |
| US-023 | Complete Review with Summary | P-002 | medium | draft |

### Group 4: Task Queue (Priority: High, prd_group: tasks)
Stories for task management and queue operations.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-014 | Pick Up Task from Queue | P-001 | high | draft |
| US-015 | View Task Queue Progress | P-002 | high | draft |
| US-016 | Create Task in Queue | P-003 | high | draft |
| US-017 | Link Artifact to Task | P-001 | high | draft |
| US-018 | Update Task Status | P-001 | high | draft |
| US-026 | Ask Question on Task | P-001 | medium | draft |
| US-030 | Assign Task Complexity | P-001 | low | draft |

### Group 5: Browser/Screenshots (Priority: Medium, prd_group: browser)
Stories for browser automation and visual testing.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-012 | Capture Screenshot of Current Work | P-003 | medium | draft |
| US-013 | Compare Screenshots for Visual Regression | P-001 | medium | draft |
| US-019 | Automate Form Submission | P-001 | medium | draft |
| US-020 | Quick Form Fill for Developers | P-003 | medium | draft |
| US-021 | Navigate and Interact with Web Pages | P-001 | medium | draft |
| US-024 | Manage Browser Session State | P-001 | low | draft |
| US-029 | Inject Scripts and Styles | P-001 | low | draft |

### Group 6: Agent Coordination (Priority: High, prd_group: coordination)
Stories for monitoring and coordinating AI agents (Project Manager persona).

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-031 | View Agent Work Logs | P-004 | high | draft |
| US-032 | Assign Tasks to Specific Agents | P-004 | high | draft |
| US-033 | Monitor Sprint Progress with Agent Metrics | P-004 | medium | draft |

### Group 7: Human-Agent Collaboration (Priority: High, prd_group: collaboration)
Stories for developer-AI pair programming workflows (Dave P-005 persona).

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-034 | Review Agent-Generated Code | P-005 | high | draft |
| US-035 | Share Architectural Context with Agents | P-005 | high | draft |
| US-036 | Pair Program via Chat Room | P-005 | medium | draft |
| US-037 | Track Code Quality Metrics for Agent Output | P-005 | low | draft |

## User Story Structure

Each user story file follows a consistent template:

```markdown
# User Story: {Title}

**ID**: US-XXX
**Persona**: P-XXX ({Persona Name})
**Priority**: critical|high|medium|low
**Status**: draft|in_progress|done|blocked
**Created**: {ISO 8601 timestamp}

## Story

As a **{persona role}**,
I want to **{capability}**,
So that **{benefit or outcome}**.

## Acceptance Criteria

- [ ] {Testable requirement 1}
- [ ] {Testable requirement 2}
- [ ] ...

## Notes

{Implementation hints, edge cases, design considerations}

## Dependencies

{Related user stories or system requirements}

## Open Questions

{Unresolved design decisions or clarifications needed}

## Related Commands

{MCP tools or CLI commands relevant to this story}
```

## File Naming Convention

User stories follow the pattern: `US-XXX-slugified-title.md`

- `XXX`: 3-digit sequential number (001-037)
- `slugified-title`: lowercase with hyphens

## Example Stories

### US-001: Load NPL Core Components
Critical priority story for AI Agent persona. Defines how agents load NPL syntax, conventions, and protocols when starting a session. Acceptance criteria include loading core syntax, agent protocols, and handling selective component loading.

### US-003: Fetch Web Content as Markdown
High priority story for Vibe Coder persona. Captures need to quickly fetch and convert web documentation to markdown for reference. Uses `web_to_md` tool with timeout handling.

### US-034: Review Agent-Generated Code
High priority story for Dave (Fellow Developer) persona. Addresses human review workflow for agent-generated code with inline comments, diff views, and revision requests. Demonstrates cross-persona collaboration.

See individual story files in `docs/user-stories/` for complete examples.

## index.yaml

The `index.yaml` file is managed by the `idea-to-spec` agent using `yq`. It contains:

- `version`: Index format version
- `updated`: Last timestamp
- `stories`: Array of story objects with:
  - `id`: Story identifier (US-XXX)
  - `title`: Human-readable title
  - `file`: Filename
  - `persona`: Associated persona ID
  - `priority`: critical/high/medium/low
  - `status`: draft/in_progress/done/blocked
  - `prd_group`: Functional group
  - `collaborators`: Optional list of collaborator personas

## Personas Reference

| ID | Name | Role |
|----|------|------|
| P-001 | AI Agent | Autonomous, programmatic automation agent |
| P-002 | Product Manager | Non-technical reviewer needing dashboards |
| P-003 | Vibe Coder | Developer focused on rapid prototyping |
| P-004 | Project Manager | Coordinates agents, sprint planning, task tracking |
| P-005 | Dave | Senior developer focused on code review and quality |

## Story Workflow

1. **Creation** - `idea-to-spec` agent generates stories from feature ideas
2. **Specification** - `prd-editor` refines stories and creates detailed PRDs
3. **Test Creation** - `tdd-tester` writes test suites based on acceptance criteria
4. **Implementation** - `tdd-coder` implements features to pass tests
5. **Review** - Code review and story completion verification

See [docs/arch/agent-orchestration.md](/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/arch/agent-orchestration.md) for detailed agent workflow.