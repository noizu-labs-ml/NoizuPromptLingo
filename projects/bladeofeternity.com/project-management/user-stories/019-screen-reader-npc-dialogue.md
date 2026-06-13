# US-019: Screen Reader Accessible NPC Dialogue and Branching Choices

**Persona:** Jamie — Sighted IF enthusiast, literature grad student; Elena — Blind teenager
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Elena, I want NPC dialogue and conversation choices to be fully navigable by screen reader so that I experience the full narrative depth of the game without any content being visually gated.

## Acceptance Criteria
- [ ] NPC dialogue text appears in a dedicated `role="dialog"` or prominent `<section>` with `aria-label="Dialogue: [NPC Name]"` and focus moves to it automatically when a conversation begins
- [ ] The NPC's name and dialogue text are in the reading order before the response choices — screen reader users hear the prompt before the options
- [ ] Response choices are implemented as `role="radiogroup"` or a numbered list of buttons; each choice is fully readable without abbreviation
- [ ] Selecting a response and pressing Enter advances the dialogue; the new dialogue text is announced via live region or focus movement
- [ ] Branching choice consequences (visible to sighted users via tooltips) are exposed via `aria-describedby` on each choice button
- [ ] Dialogue history is reviewable — a "Review conversation" link opens a scrollable log of the current NPC conversation
- [ ] Pressing Escape during dialogue offers a "Leave conversation?" confirmation before dismissing
- [ ] No dialogue content is conveyed through images or icons without text equivalents

## Notes
Jamie's literary perspective demands that the narrative writing itself is not degraded by accessibility formatting — the solution must make NPC dialogue MORE accessible without becoming sterile. Test with long dialogue passages (200+ words) to ensure screen reader users are not overwhelmed; consider an option to pause auto-advance in cutscene-style sequences. This story has overlap with Jamie's narrative quality concerns (US-series 040+).
