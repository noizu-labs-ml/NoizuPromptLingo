# PRD-010: MCP Tools Implementation

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The NPL MCP server architecture documents 23 tools across 4 functional domains, but only 2 tools are currently implemented (init-project, hello-world), representing a 91% implementation gap. This PRD defines the complete implementation of all MCP tools required for artifact management, chat room collaboration, task queue coordination, and browser automation workflows.

**Current State**:
- 23 tools documented in architecture
- 2 tools implemented (init-project family)
- 21 tools pending implementation (91% gap)

**Target State**:
- Full implementation of all 23 documented tools
- SQLite-backed persistence for all domain managers
- Comprehensive test coverage for each tool

## Goals

1. Implement all 27 MCP tools across 4 functional domains
2. Achieve >90% test coverage for all manager classes
3. Ensure tool response time <500ms for standard operations
4. Enable cross-domain integration (artifacts ↔ tasks ↔ chat)
5. Support concurrent operations with race condition prevention

## Non-Goals

- Migration of existing project initialization tools (already implemented)
- Real-time WebSocket notifications (future work)
- Multi-tenant support (single project scope)
- Advanced workflow automation (future work)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-114 | [MCP Artifact Management Tools](../../user-stories/US-114-mcp-artifact-management-tools.md) | P-001 | high |
| US-115 | [MCP Chat Collaboration Tools](../../user-stories/US-115-mcp-chat-collaboration-tools.md) | P-001 | high |
| US-116 | [MCP Task Queue Tools](../../user-stories/US-116-mcp-task-queue-tools.md) | P-001 | high |
| US-117 | [MCP Browser Automation Tools](../../user-stories/US-117-mcp-browser-automation-tools.md) | P-001 | medium |
| US-118 | [MCP Cross-Domain Integration Tools](../../user-stories/US-118-mcp-cross-domain-integration-tools.md) | P-001 | medium |

**Note**: Legacy range-based IDs (US-008-030, US-031-045, etc.) have been consolidated to individual global IDs (US-114 through US-118).

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

### Artifact Management Tools (6 tools)
- **FR-001**: [create_artifact](./functional-requirements/FR-001-create-artifact.md)
- **FR-002**: [version_artifact](./functional-requirements/FR-002-version-artifact.md)
- **FR-003**: [create_review](./functional-requirements/FR-003-create-review.md)
- **FR-004**: [add_inline_comment](./functional-requirements/FR-004-add-inline-comment.md)
- **FR-005**: [complete_review](./functional-requirements/FR-005-complete-review.md)
- **FR-006**: [annotate_screenshot](./functional-requirements/FR-006-annotate-screenshot.md)

### Chat Room Tools (7 tools)
- **FR-007**: [create_chat_room](./functional-requirements/FR-007-create-chat-room.md)
- **FR-008**: [send_message](./functional-requirements/FR-008-send-message.md)
- **FR-009**: [react](./functional-requirements/FR-009-react.md)
- **FR-010**: [share_artifact](./functional-requirements/FR-010-share-artifact.md)
- **FR-011**: [create_todo](./functional-requirements/FR-011-create-todo.md)
- **FR-012**: [receive_notifications](./functional-requirements/FR-012-receive-notifications.md)
- **FR-013**: [role_based_access](./functional-requirements/FR-013-role-based-access.md)

### Task Queue Tools (7 tools)
- **FR-014**: [create_task](./functional-requirements/FR-014-create-task.md)
- **FR-015**: [pick_task](./functional-requirements/FR-015-pick-task.md)
- **FR-016**: [update_status](./functional-requirements/FR-016-update-status.md)
- **FR-017**: [assign_task](./functional-requirements/FR-017-assign-task.md)
- **FR-018**: [link_artifact](./functional-requirements/FR-018-link-artifact.md)
- **FR-019**: [ask_question](./functional-requirements/FR-019-ask-question.md)
- **FR-020**: [assign_complexity](./functional-requirements/FR-020-assign-complexity.md)

### Browser Automation Tools (7 tools)
- **FR-021**: [navigate](./functional-requirements/FR-021-navigate.md)
- **FR-022**: [screenshot](./functional-requirements/FR-022-screenshot.md)
- **FR-023**: [form_fill](./functional-requirements/FR-023-form-fill.md)
- **FR-024**: [compare_screenshots](./functional-requirements/FR-024-compare-screenshots.md)
- **FR-025**: [manage_session](./functional-requirements/FR-025-manage-session.md)
- **FR-026**: [inject_scripts](./functional-requirements/FR-026-inject-scripts.md)
- **FR-027**: [timeout_retry](./functional-requirements/FR-027-timeout-retry.md)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 90% |
| NFR-2 | Tool response time | P95 latency | <= 500ms |
| NFR-3 | Database persistence | State survival | 100% across restarts |
| NFR-4 | Concurrency safety | Race conditions | 0 detected |
| NFR-5 | Error messages | Actionable clarity | 100% of errors |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Resource not found | NotFoundError | "Resource {type} with ID {id} not found" |
| Permission denied | PermissionError | "Insufficient permissions to access {resource}" |
| Validation failure | ValidationError | "Invalid input: {field} {reason}" |
| Conflict | ConflictError | "{Resource} already exists with name {name}" |
| Timeout | TimeoutError | "Operation timed out after {duration}ms" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key test categories:
- **Integration Tests** (AT-001 through AT-007): Domain-specific workflows
- **End-to-End Tests** (AT-008): Full MCP tool invocation via STDIO

---

## Technical Architecture

### Manager Pattern

Each tool domain is implemented via a dedicated manager class:

```
ArtifactManager  (6 tools)
ChatManager      (7 tools)
TaskManager      (7 tools)
BrowserManager   (7 tools)
```

### FastMCP Integration

All managers initialized via FastMCP lifespan hooks and registered as tools.

### Database Schema

Three SQLite databases:
- `artifacts.db`: Artifacts, versions, reviews, comments
- `chat.db`: Rooms, events, members, todos
- `tasks.db`: Tasks, labels, artifacts, questions

---

## Success Criteria

1. **Tool Coverage**: All 27 documented tools implemented and registered
2. **Test Coverage**: >90% coverage for all manager classes
3. **Performance**: Tool response time <500ms for standard operations
4. **Persistence**: All state survives server restart
5. **Concurrency**: Race conditions prevented for atomic operations
6. **Error Handling**: Graceful failures with actionable error messages

---

## Out of Scope

- Migration of existing project initialization tools
- Real-time WebSocket notification system
- Multi-tenant or multi-project support
- Advanced workflow automation engine
- UI components for tool visualization

---

## Dependencies

- **FastMCP 2.x**: MCP server framework
- **SQLite**: Persistence layer
- **Playwright**: Browser automation
- **Pillow**: Image comparison
- **pytest**: Testing framework
- **pytest-asyncio**: Async test support

---

## Open Questions

- [ ] Browser automation: Use Playwright or Selenium?
- [ ] Image comparison: Pixel-perfect or perceptual diff?
- [ ] Notification delivery: Push or poll?
- [ ] Session timeout: Default duration?
