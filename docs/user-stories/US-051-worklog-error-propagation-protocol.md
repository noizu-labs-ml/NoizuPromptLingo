# US-051 - Worklog Error Propagation Protocol

**ID**: US-051
**Persona**: P-001 - AI Agent
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an AI agent, I need to report errors to the session worklog in a standardized format so that parent agents and peers can react appropriately.

## Acceptance Criteria

- [ ] Standard error entry schema in `worklog.jsonl`: `{"action": "error", "agent_id": "...", "error_type": "...", "error_msg": "...", "stack_trace": "...", "recovery_hint": "..."}`
- [ ] Parent agents subscribe to error events via cursor-based reads
- [ ] Error severity levels: recoverable, blocking, fatal
- [ ] Auto-routing: blocking errors trigger tdd-debugger invocation
- [ ] Recovery hints guide parent on retry vs. escalation
- [ ] Integration with existing `npl-session log` command

## Technical Notes

This story extends the agent orchestration workflow documented in `docs/arch/agent-orchestration.md`. It establishes a standardized error propagation protocol that enables agents to communicate failures and recovery strategies through the worklog system.

## Dependencies

- Related stories: None
- Related personas: P-001
