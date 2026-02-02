# User Story: Share Artifact in Chat Room

**ID**: US-004
**Persona**: P-003 (Vibe Coder)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **share an artifact in a chat room**,
So that **my team can see and discuss my work without leaving the conversation**.

## Acceptance Criteria

- [ ] Can share any artifact by ID in a chat room
- [ ] Can optionally specify a particular revision (version number)
- [ ] Shared artifact appears inline in chat feed
- [ ] Other participants can view the artifact directly
- [ ] Sharing creates a chat event in the room's feed
- [ ] Defaults to latest revision if none specified
- [ ] Returns shared_artifact_id for reference

## Notes

- Shared artifacts reference a specific revision by default (the latest at share time)
- If artifact is updated (new revision created), the share still points to the original revision
- Consider showing inline preview for images and short text/markdown documents
- Should work with all artifact types (markdown, images, code, etc.)
- Large artifacts (images, long documents) may show preview with link to full view

## Dependencies

- Artifact must exist (US-008)
- Chat room must exist (US-007)

## Open Questions

- Should sharing notify room members (generate notifications)?
- Should users be able to re-share with a different revision?
- How to display artifact metadata (name, type, creator) in the share preview?

## Related Commands

- `share_artifact` (Chat / Room Tools)
- `get_artifact` (Artifact Tools)
- `get_chat_feed` (Chat / Room Tools)
