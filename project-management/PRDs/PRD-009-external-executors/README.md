# PRD-009: External Executors

**Version**: 1.0
**Status**: Implemented (Not Exposed)
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

Infrastructure for ephemeral tasker agents with automatic lifecycle management and Fabric CLI integration for LLM-based output analysis. Complete implementation exists but MCP tools are not currently exposed.

## Goals

1. Provide ephemeral tasker agents with automatic lifecycle management
2. Integrate Fabric CLI for intelligent output analysis
3. Expose tasker management as MCP tools for Claude integration
4. Support context buffering for follow-up queries
5. Enable nag messages and auto-termination for abandoned tasks

## Non-Goals

- Long-running persistent agents (agents auto-terminate)
- Direct Fabric pattern development (use existing patterns only)
- Web UI for tasker management (future PRD)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority | Status |
|----|-------|---------|----------|--------|
| US-111 | [Ephemeral Tasker Lifecycle Management](../../user-stories/US-111-ephemeral-tasker-lifecycle.md) | P-001 | high | draft |
| US-112 | [Fabric CLI Integration](../../user-stories/US-112-fabric-cli-integration.md) | P-001 | medium | draft |
| US-113 | [MCP Tool Exposure for Taskers](../../user-stories/US-113-mcp-tool-exposure-for-taskers.md) | P-001 | critical | draft |

**Note**: Legacy IDs US-009-001, US-009-002, US-009-003 have been consolidated to global IDs US-111, US-112, US-113.

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Ephemeral Tasker Lifecycle Management](./functional-requirements/FR-001-tasker-lifecycle-management.md) - Auto-terminate, nag messages, context buffering
- **FR-002**: [Fabric CLI Integration](./functional-requirements/FR-002-fabric-cli-integration.md) - Pattern application, auto-detection, graceful fallback
- **FR-003**: [MCP Tool Exposure](./functional-requirements/FR-003-mcp-tool-exposure.md) - Register all tools in unified.py

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Lifecycle monitoring overhead | CPU usage | < 5% |
| NFR-3 | Nag message latency | Response time | < 2 seconds |
| NFR-4 | Fabric timeout | Max execution time | 30 seconds |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Tasker not found | ValueError | "Tasker {id} not found or terminated" |
| Fabric not installed | RuntimeError | "Fabric CLI not installed. See installation instructions." |
| Pattern not found | ValueError | "Pattern '{name}' not found. Available: {list}" |
| Timeout exceeded | TimeoutError | "Tasker {id} auto-terminated after {timeout} minutes" |
| Invalid lifecycle state | ValueError | "Cannot {action} tasker in {state} state" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key tests:
- **AT-001**: [Tasker Spawn and Lifecycle](./acceptance-tests/AT-001-tasker-spawn-and-lifecycle.md)
- **AT-002**: [Context Buffering](./acceptance-tests/AT-002-context-buffering.md)
- **AT-003**: [Fabric Pattern Application](./acceptance-tests/AT-003-fabric-pattern-application.md)
- **AT-004**: [MCP Tool Registration](./acceptance-tests/AT-004-mcp-tool-registration.md)

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code
3. All acceptance tests passing
4. MCP tools registered and invokable
5. Fabric integration working with graceful fallback
6. Lifecycle monitoring stable for 24+ hours
7. Nag messages delivered within 2 seconds

---

## Out of Scope

- Web UI for tasker dashboard (future PRD-007 enhancement)
- Real-time WebSocket updates (future enhancement)
- Tasker-to-tasker communication (not needed for MVP)
- Custom Fabric pattern development (use existing patterns)
- Task queue integration (covered by PRD-005)

---

## Dependencies

**Internal**:
- Chat Manager (nag messages)
- Session Manager
- Database (taskers table)

**External**:
- Fabric CLI (optional, github.com/danielmiessler/fabric)
- asyncio

---

## Implementation Notes

**Implementation Status**: ⚠️ Complete implementation exists in codebase:
- `src/npl_mcp/executors/manager.py` - TaskerManager class
- `src/npl_mcp/executors/fabric.py` - Fabric integration
- Database schema: `taskers` table with lifecycle fields

**Critical Gap**: Zero MCP tools exposed in `unified.py`. Need to register:
- `spawn_tasker`, `get_tasker`, `list_taskers`, `dismiss_tasker`, `keep_alive_tasker`
- `apply_fabric_pattern`, `analyze_with_fabric`, `list_fabric_patterns`

---

## Open Questions

- [ ] Should lifecycle monitor start automatically or on-demand?
- [ ] What is the default model for Fabric CLI?
- [ ] Should tasker context be stored in separate table or JSON field?
- [ ] How to handle nag messages when chat room is closed?
