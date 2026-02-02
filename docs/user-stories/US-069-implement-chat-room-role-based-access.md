# US-069 - Implement Chat Room Role-Based Access

**ID**: US-069
**Persona**: P-004 - Project Manager
**PRD Group**: chat
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I need to assign roles (admin, contributor, observer) to chat room members so that I can control who can post messages, share artifacts, or modify room settings.

## Acceptance Criteria

- [ ] Chat rooms support roles: `owner`, `admin`, `contributor`, `observer`
- [ ] Owners can assign/revoke roles and delete rooms
- [ ] Admins can manage members and moderate content
- [ ] Contributors can send messages and react
- [ ] Observers can read but not post
- [ ] MCP tools enforce role checks before `send_message`, `share_artifact`, `create_todo`

## Technical Notes

The current architecture tracks chat room membership but lacks permission levels (admin, contributor, read-only). This story extends the existing chat room functionality to add role-based access control.

Implementation will require:
- Database schema changes: Add role column to chat room membership
- Updates to ChatManager: Enforce role checks
- MCP tool updates: Add role parameter to join/invite operations
- UI updates: Display role badges and enforce client-side restrictions

## Dependencies

- Related stories: US-007
- Related personas: P-004
