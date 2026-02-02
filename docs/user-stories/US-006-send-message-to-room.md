# User Story: Send Message to Chat Room

**ID**: US-006
**Persona**: P-003 (Vibe Coder)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **send a quick message to a chat room**,
So that **I can communicate updates, questions, or ideas to my team without formal documentation**.

## Acceptance Criteria

- [ ] Can send text message to any chat room by room ID
- [ ] Message attributed to sending persona (agent or user)
- [ ] Message appears in room's chat feed immediately
- [ ] Returns unique event ID for message tracking (enables reactions, threading)
- [ ] Supports @mentions syntax to notify specific participants
- [ ] Messages support markdown formatting (code blocks, links, emphasis)
- [ ] Message timestamp captured automatically
- [ ] Empty or whitespace-only messages rejected

## Notes

- This is the primary communication channel for informal updates and collaboration
- Should be fast - minimal overhead, immediate delivery
- Event ID enables future features: reactions (US-027), threading, message editing
- Markdown rendering happens client-side for performance
- Messages are append-only (immutable once sent)

## Dependencies

- US-007: Chat room must exist before messages can be sent

## Open Questions

- Should @mentions trigger notifications automatically? (Likely yes, see US-022)
- Maximum message length limit? (Suggest 10,000 characters for chat messages)
- Should message delivery be confirmed with acknowledgment?
- Rate limiting to prevent spam?

## Related Commands

- `send_message` (Chat Tools) - Primary command for this story
- `get_chat_feed` (Chat Tools) - View messages after sending
- `react_to_message` (Chat Tools) - Interact with sent messages (US-027)
