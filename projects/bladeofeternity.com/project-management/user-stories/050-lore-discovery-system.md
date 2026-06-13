# US-050: Lore Discovery System

**Persona:** Lena — Sighted Tabletop RPG Player / English Teacher
**Priority:** P1
**Epic:** World & Narrative

## Story
As Lena, I want to discover lore organically through examination, NPC conversation, and environmental detail — building a personal codex of what my character has learned — so that world-building feels earned rather than delivered in exposition dumps.

## Acceptance Criteria
- [ ] `examine <object|npc|location>` can surface lore fragments not present in the base room description
- [ ] Discovered lore is added to the player's `codex` — accessible via `codex` or `codex search <term>`
- [ ] Codex entries are written in the same AI narrative voice as room descriptions — no dry encyclopaedia prose
- [ ] Lore can be discovered in layers: a second `examine` after gaining new knowledge or reputation may reveal more
- [ ] NPCs can be asked about codex topics: `ask <npc> about <codex term>` produces contextually appropriate response
- [ ] Lore entries reference each other via in-text links: `[see: the Veil of Mordoon]` which players can follow via `codex the Veil of Mordoon`
- [ ] `codex` command output is screen-reader navigable — entries are a flat list, no nested structure requiring complex navigation
- [ ] Lore is character-specific: two characters can have different codex states based on their discoveries

## Notes
- Lena plays in short sessions (30–45 min); codex should be skimmable in a brief session review
- "Night at Mordoon" Twine lore is the canonical seed dataset — key passages should become discoverable codex entries
- Examine depth gating (more lore revealed after reputation gain) must not feel arbitrary or punishing
- Lore fragment generation can be AI-assisted but must be reviewed/curated to maintain consistency with established canon
- Cross-referencing between codex entries must be maintained by the narrative team — AI should not auto-generate cross-refs
