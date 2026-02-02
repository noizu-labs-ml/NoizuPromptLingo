# User Story: Ephemeral Tasker Lifecycle Management

**ID**: US-111
**Legacy ID**: US-009-001
**Persona**: P-001 (AI Agent)
**PRD Group**: coordination
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-009

## Story

As a **system architect**,
I want **ephemeral tasker agents with automatic lifecycle management**,
So that **long-running sub-tasks can be managed without manual cleanup**.

## Acceptance Criteria

- [ ] Taskers spawn with configurable timeout (default 15 minutes)
- [ ] Taskers send nag messages after idle period (default 5 minutes)
- [ ] Taskers auto-terminate after timeout if no activity
- [ ] Taskers maintain lifecycle states: IDLE, ACTIVE, NAGGING, TERMINATED
- [ ] Context buffering for follow-up queries
- [ ] In-memory state cache with persistent DB storage

## Notes

- Story points: 8
- Related personas: system-architect, developer

## Dependencies

- PRD-009 External Executors infrastructure

## Related Commands

- `spawn_tasker` - Spawn ephemeral tasker agent
- `get_tasker` - Get tasker state
- `dismiss_tasker` - Terminate tasker
