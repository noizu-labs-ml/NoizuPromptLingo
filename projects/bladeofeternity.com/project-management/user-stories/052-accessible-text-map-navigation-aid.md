# US-052: Accessible Text Map and Navigation Aid

**Persona:** Elena — Blind Teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** World & Exploration

## Story
As Elena, I want a spatial navigation aid that describes my position and connectivity in terms I can understand without a visual map so that I can orient myself and plan movement as effectively as sighted players using a minimap.

## Acceptance Criteria
- [ ] `map` command outputs a text adjacency description: current room, all connected rooms, and the exit direction to reach each
- [ ] `map area` outputs a wider view — all rooms within 2 hops, organized by direction cluster
- [ ] Output is structured as a screen-reader-friendly list, not ASCII art (ASCII art is opt-in via `/set map-style ascii`)
- [ ] `surroundings` command gives a compass-rose style summary ("North: The Tanner's Alley. East: Market Square. No exit south or west.")
- [ ] Player's position within a district is always inferable from `whereis` without needing to `map`
- [ ] Navigation history (`breadcrumbs`) shows the last 10 rooms visited with exits taken to reach each
- [ ] All navigation aid commands produce output < 200 words to avoid VoiceOver read time fatigue
- [ ] ASCII map mode (opt-in) uses only characters with unambiguous VoiceOver pronunciation; walls use `#`, rooms use `[+]`, exits use cardinal letters

## Notes
- Elena plays on iPhone; all commands must work on mobile keyboard/braille display input
- ASCII art map is explicitly opt-in — the default must work excellently for screen readers
- VoiceOver on iOS has known quirks with certain Unicode characters — ASCII map mode should test against iOS VoiceOver specifically
- Navigation aid should update reactively when player moves without requiring re-issuing the `map` command in verbose mode
- Priya (persona 04) will test this against JAWS, NVDA, and VoiceOver to validate cross-reader output
