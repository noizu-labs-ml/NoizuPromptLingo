# US-054: Examine Command and Layered Discovery

**Persona:** Lena — Sighted Tabletop RPG Player / English Teacher
**Priority:** P1
**Epic:** World & Exploration

## Story
As Lena, I want the `examine` command to reward attention — revealing more detail on focused inspection than the room description provides — so that careful observation feels like a player skill rather than clicking through dialogue menus.

## Acceptance Criteria
- [ ] `examine <target>` produces a focused description distinct from the room's ambient text
- [ ] Examined objects can contain nested examinations (`examine the inscription on the wall` after `examine the wall`)
- [ ] Some examine results reveal actionable information (hidden exits, lore fragments, interactable objects)
- [ ] Examine results vary based on character skills/background (a scholar sees the inscription's language; a thief notices the loose stone)
- [ ] `examine room` re-reads the room description with slightly elevated focus — equivalent to reading more carefully
- [ ] All examine results are screen-reader appropriate — no visual-only information delivery
- [ ] Examining the same object twice can return elaborated descriptions if the player has gained knowledge since the first examine
- [ ] `examine` history is not stored globally — each session starts fresh, but knowledge gained persists in the codex

## Notes
- Lena plays in short sessions; examine chains should reward focused play without requiring marathon exploration
- Nested examine depth: maximum 3 levels deep to avoid combinatorial explosion
- Character-skill variation in examine must not punish blind players — all players can discover all critical information, just through different examine framings
- Priya will verify that examine output regions have correct ARIA live settings to avoid double-announcement with screen readers
- "examine room" as a full re-read is useful for screen reader users who want to re-hear description without triggering a new AI generation
