# US-018: Fully Accessible Character Creation Flow

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Elena, I want to create my character independently using VoiceOver so that my first experience of the game is empowering and equal to my sighted friends' experience, without needing help navigating the UI.

## Acceptance Criteria
- [ ] Character creation is a multi-step wizard implemented as a sequence of `<section>` regions, each with a clear `<h2>` identifying the current step
- [ ] Step progress is announced: "Step 2 of 5: Choose your class" via `aria-live="polite"` on step change
- [ ] Race and class selection uses `role="radiogroup"` with `role="radio"` options; each option includes a text description of lore and stat implications (not just the name)
- [ ] Stat allocation uses accessible number inputs (`<input type="number">`) with `aria-describedby` pointing to the stat description and current total remaining
- [ ] Visual character model preview (if present) has a text alternative describing the character's appearance based on current selections
- [ ] Name input validates in real time; errors are announced via `aria-live="assertive"`: "Name already taken. Please choose another."
- [ ] "Back" and "Next" step navigation is keyboard accessible; moving back does not reset filled fields
- [ ] Final confirmation step reads back all selections before submission

## Notes
Character creation is the first interaction and sets the emotional tone. A failed or confusing creation experience will cause Elena to abandon the game before she plays. VoiceOver on iOS handles radio groups differently than desktop — test thoroughly. The stat allocation step is the most complex: ensure remaining-points count updates correctly in the `aria-describedby` text without triggering excessive screen reader chatter.
