# User Story: MCP Chat Collaboration Tools

**ID**: US-115
**Legacy ID**: US-031-045
**Persona**: P-001 (AI Agent)
**PRD Group**: mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-010

## Story

As a **team lead**,
I want **to collaborate through persistent chat rooms with reactions and todos via MCP tools**,
So that **I can coordinate work with other agents and maintain context across sessions**.

## Acceptance Criteria

- [ ] Can create persistent chat rooms with visibility controls
- [ ] Can send messages with markdown and threading support
- [ ] Can add emoji reactions to messages
- [ ] Can share artifacts in chat rooms with previews
- [ ] Can create todos linked to messages and rooms
- [ ] Can receive notifications for mentions and updates
- [ ] Can manage role-based access for room members

## Notes

- Story points: 13
- Related personas: team-lead, collaborator
- Consolidates stories US-031 through US-045 scope

## Dependencies

- PRD-004 Chat and Sessions
- PRD-010 MCP Tools Implementation

## Related Commands

- `create_chat_room` - Create chat room
- `send_message` - Send message
- `react` - Add reaction
- `share_artifact` - Share artifact in chat
- `create_todo` - Create todo from chat
- `receive_notifications` - Get notifications
