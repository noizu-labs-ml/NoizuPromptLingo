# US-072 - Implement Persona Permission Scopes

**ID**: US-072
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I need to define permission scopes for personas (read-only, contributor, admin) so that automated agents can't accidentally delete critical artifacts or modify project settings.

## Acceptance Criteria

- [ ] Personas have assigned scope: `read-only`, `contributor`, `admin`, `system`
- [ ] `read-only` personas can only read artifacts and chat
- [ ] `contributor` personas can create artifacts and chat, but not delete
- [ ] `admin` personas can perform all operations
- [ ] `system` personas have unrestricted access
- [ ] MCP server checks persona scope before executing privileged operations
- [ ] Scope violations return `403 Forbidden` with clear error message

## Technical Notes

The current persona system (file-backed with no encryption, access logs, or multi-user isolation) lacks any authorization framework. This story adds a scope/permission model to prevent automated agents from performing destructive operations.

Implementation will require:
- Persona metadata: Add `scope` field to persona definitions
- MCP middleware: Check scope before executing operations
- Database schema: Track persona scope in runtime session data
- Error handling: Return clear authorization failures
- Integration with audit logging (US-070)

This is complementary to artifact-level ACLs (US-068) - scopes define what a persona can do globally, while ACLs define access to specific resources.

## Dependencies

- Related stories: None (foundational security story)
- Related personas: P-004
