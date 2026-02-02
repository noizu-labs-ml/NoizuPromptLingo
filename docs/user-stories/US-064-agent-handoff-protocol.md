# US-064 - Agent Handoff Protocol

**ID**: US-064
**Persona**: P-001 - AI Agent
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an autonomous agent, I want a standardized handoff protocol to transfer task ownership to another agent so that context is preserved across agent transitions.

## Acceptance Criteria

- [ ] Handoff includes task summary, context, blockers, and next steps
- [ ] Receiving agent acknowledges handoff and asks clarifying questions
- [ ] Handoff logged to session worklog with both agents' IDs
- [ ] Handoff reasons tracked (completion, delegation, escalation, blocked)
- [ ] Task status updated atomically during handoff
- [ ] Previous agent remains available for follow-up questions

## Technical Notes

Current task assignment is one-way. No handoff protocol or context transfer mechanism exists.

## Dependencies

- Related stories: US-032
- Related personas: P-001

## Context

This story extends US-032 (Assign Tasks to Specific Agents) with a structured handoff mechanism. It ensures that when agents transfer tasks between each other, all necessary context is preserved and transitions are properly logged.
