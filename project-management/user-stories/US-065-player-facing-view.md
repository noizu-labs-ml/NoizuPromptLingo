---
id: US-065
title: "Player-Facing View (Spoiler-Free)"
slug: "player-facing-view"
personas: [P-002]
epic: "Session Companion"
priority: "should-have"
complexity: "M"
tags: [session, players, spoilers, sharing, view, gm]
---

# US-065: Player-Facing View (Spoiler-Free)

## User Story

**As a** veteran game master (P-002),
**I want to** share a filtered, spoiler-free view of select canon entries with my players,
**So that** they can reference established world lore without seeing GM-only content, plot spoilers, or hidden NPC motivations.

## Acceptance Criteria

- [ ] Given a canon entry has a "visibility" field, when I set it to "player-visible," then that entry appears in the player-facing view accessible via a shareable link, while entries marked "gm-only" or "private" are excluded.
- [ ] Given a player-facing entry contains sections tagged "gm-only," when a player accesses the view via the share link, then those sections are hidden and no indication of their existence is shown (not even a redacted placeholder).
- [ ] Given I generate a player-facing share link, when I share it, then recipients can view the filtered entries without creating an account and without being able to edit any content.
- [ ] Given I revoke a player-facing share link, when the revocation is confirmed, then any subsequent access to that link returns a "this view is no longer available" page within 60 seconds of revocation.

## Notes

Player-facing view is read-only and unauthenticated (link-based). Depends on US-063 (session log) for session context awareness. Related: US-067 (share session entries), US-061 (quick-reference search).
