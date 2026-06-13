# US-070 - Generate Audit Logs for Sensitive Operations

**ID**: US-070
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: coordination
**Priority**: critical
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a senior developer, I need comprehensive audit logs showing who accessed, modified, or deleted artifacts and chat rooms so that I can investigate security incidents and ensure compliance.

## Acceptance Criteria

- [ ] All artifact operations (create, read, update, delete) log to audit table
- [ ] All chat operations (join, leave, delete room) log to audit table
- [ ] All review operations (create, add comment, complete) log to audit table
- [ ] Audit entries include: timestamp, persona/user ID, operation type, resource ID, IP address (if available)
- [ ] Audit logs are immutable (append-only)
- [ ] Query interface allows filtering by persona, operation, date range

## Technical Notes

This is a cross-cutting concern that affects all major bounded contexts (NPL Framework, MCP Tooling, Personas). The event-sourced chat system provides immutability but no authorization checks on event creation.

Implementation will require:
- New database schema: Audit table with appropriate indexes
- Audit hooks in all managers: ArtifactManager, ChatManager, ReviewManager
- New MCP query tools: `query_audit_log` with filtering capabilities
- Integration with ACL system (US-068, US-069)
- Optional: Integration with external SIEM systems

## Dependencies

- Related stories: None (foundational security story)
- Related personas: P-005
