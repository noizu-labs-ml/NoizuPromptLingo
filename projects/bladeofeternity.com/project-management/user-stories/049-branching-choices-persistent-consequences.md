# US-049: Branching Choices with Persistent Consequences

**Persona:** Jamie — Sighted IF Enthusiast / Literature Grad Student
**Priority:** P0
**Epic:** Quest & Narrative

## Story
As Jamie, I want choices like "the mask or the knife" to have persistent, world-visible consequences so that my decisions feel morally weighty and I can trace their effects through the narrative over time.

## Acceptance Criteria
- [ ] Binary and multi-path choice moments are presented as prose with clear action prompts (e.g., `take the mask` / `take the knife`)
- [ ] Each path produces a distinct immediate narrative outcome communicated in second-person prose
- [ ] Choices are recorded per character in a consequence log accessible via `history choices`
- [ ] Consequences manifest in subsequent NPC dialogue, room descriptions, and available quest hooks
- [ ] At least one major consequence must be visible to other players in the world (a changed NPC disposition, a room that has shifted, a faction that remembers)
- [ ] Choices cannot be undone — no retry, no save-scum; the `history choices` command makes this design intent explicit
- [ ] AI-generated follow-on content references prior choices without requiring the player to re-explain them
- [ ] Choice points are discoverable through narrative, not flagged with UI affordances

## Notes
- "The mask or the knife" is the canonical design example — it should be implemented as the first consequence-tracked choice in Mordoon
- Jamie values narrative craft; choice text must read as prose, not as UI ("You may take the mask. You may take the knife." — not "Option A / Option B")
- Consequence log format must be screen-reader friendly — structured list, no tables
- Consequence propagation latency: NPC dialogue updates within the same session; room description updates on next generation cycle
- This story intersects with Night at Mordoon heritage — some canonical Twine choices should map to in-game consequence moments
