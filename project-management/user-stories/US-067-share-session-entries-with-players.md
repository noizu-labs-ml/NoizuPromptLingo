---
id: US-067
title: "Share Session Entries with Players"
slug: "share-session-entries-with-players"
personas: [P-002]
epic: "Session Companion"
priority: "could-have"
complexity: "M"
tags: [session, sharing, players, collaboration, gm]
---

# US-067: Share Session Entries with Players

## User Story

**As a** veteran game master (P-002),
**I want to** push specific session log entries or generated lore snippets directly to my players mid-session,
**So that** I can hand players a handout (NPC description, map note, found letter) without breaking immersion or using a separate tool.

## Acceptance Criteria

- [ ] Given I select a session log entry or improvised content block, when I click "Share with Players," then the content is immediately visible in the player-facing view (US-065) under a "Session Handouts" section without requiring a page reload on the player side.
- [ ] Given a shared entry appears in the player view, when a player accesses it, then it is clearly labeled with the session name and a timestamp, and distinguished from standing canon entries.
- [ ] Given I have shared an entry with players, when I choose to retract it, then the entry is removed from the player view within 30 seconds and replaced with no indication that it previously existed.
- [ ] Given players receive a shared entry, when they view it, then they cannot edit, comment on, or forward the content from within the platform view.

## Notes

Depends on US-063 (session log), US-065 (player-facing view). "Handout" delivery is the core use case — think digital equivalent of passing a note across the table. Related: US-062 (improvise mode).
