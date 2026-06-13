# US-048 - Real-Time Agent Workflow Failure Diagnostics

**ID**: US-048
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I need to see real-time diagnostics when multi-agent workflows fail so that I can identify which agent blocked and why.

## Acceptance Criteria

- [ ] Workflow dashboard shows agent pipeline status (idea-to-spec → prd-editor → tdd-tester → tdd-coder → tdd-debugger)
- [ ] Failed agents display error type, timestamp, and blocked dependencies
- [ ] Click-through to agent worklog entries (`worklog.jsonl`) with cursor-based navigation
- [ ] Visual indication of which PRD/test/implementation artifact caused the block
- [ ] Ability to restart from failed stage after resolution

## Technical Notes

This story extends the existing agent orchestration workflow documented in `docs/arch/agent-orchestration.md`. It provides visibility into multi-agent workflow failures by integrating with the worklog system introduced in US-031.

## Dependencies

- Related stories: US-031, US-033
- Related personas: P-004
