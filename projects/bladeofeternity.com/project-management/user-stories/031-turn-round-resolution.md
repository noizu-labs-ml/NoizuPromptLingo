# US-031: Turn and Round Resolution — Timing and Narration Order

**Persona:** Priya — Sighted accessibility engineer, tests all screen readers
**Priority:** P0
**Epic:** Combat — Core Systems

## Story
As Priya, I want turn and round resolution to follow a consistent, documented narration order so that I can verify screen reader announcement correctness across NVDA, JAWS, VoiceOver, and TalkBack without encountering race conditions or dropped updates.

## Acceptance Criteria
- [ ] Round resolution order is deterministic and documented: 1) Player action declaration, 2) NPC/opponent action declaration, 3) Simultaneous resolution, 4) Status effect processing, 5) Round summary delivery
- [ ] Each phase delivered to a specific ARIA live region: declarations to `role="status"`, resolutions to `role="log"`, summary to dedicated round-summary region
- [ ] No two live regions fire simultaneously — resolution pipeline enforces sequential injection with minimum 50ms gap
- [ ] Round number announced at start of each round: "Round 4 begins."
- [ ] Timeout turns (player did not act) narrated: "You hesitate — Gareth presses the opening."
- [ ] Simultaneous resolution (both parties hit) narrated as a single compound sentence, not two separate events
- [ ] Full round transcript accessible via "Combat Log" landmark navigable by screen reader
- [ ] Cross-browser/reader test matrix documented as part of story acceptance

## Notes
Race conditions in ARIA live regions are the most common accessibility bug in this game. The 50ms sequential injection rule is a hard constraint, not a guideline. Priya will run the full NVDA/JAWS/VoiceOver/TalkBack matrix on every build. Build a test harness that can replay a round's event sequence and assert announcement order without a real browser. This story is a prerequisite for all other combat stories.
