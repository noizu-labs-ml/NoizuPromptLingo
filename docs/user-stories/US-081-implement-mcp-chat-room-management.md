# User Story: Implement MCP Chat Room Management Tools

**ID**: US-081
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**PRD Group**: mcp_tools
**Created**: 2026-02-02

## As a...
AI Agent participating in collaborative sessions

## I want to...
Create, join, list, and manage chat rooms via MCP tools with permission controls

## So that...
Multiple agents can organize work into isolated conversation spaces with controlled access

## Acceptance Criteria
- [ ] `create_room` tool creates new room with name, description, and privacy settings
- [ ] `join_room` tool allows agents to join with optional password/token auth
- [ ] `list_rooms` tool shows available rooms with filtering options
- [ ] `room_info` tool returns metadata, members, and access control info
- [ ] `update_room` tool manages room settings and member permissions
- [ ] `delete_room` tool removes room and archives chat history
- [ ] Tools support role-based access control (owner, moderator, member, viewer)

## Implementation Notes
**Gap**: Chat room storage schema, permission layer, room lifecycle management
**Documented in**: `src/npl_mcp/chat/` and `src/npl_mcp/sessions/` modules
**Current state**: Basic chat infrastructure exists; room management tools not implemented
**Dependencies**: Database schema, authentication/authorization layer

## Related Stories
- **Related**: US-006, US-007, US-088, US-089
- **PRD**: prd-009-mcp-tools-implementation
- **Personas**: P-001

## Notes
Room management is central to session organization. Should support archival and audit logging for compliance.
