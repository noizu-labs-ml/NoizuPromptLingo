# US-051: Time-of-Day and Weather Room Variation

**Persona:** Sarah — Low-Vision Player (Retinitis Pigmentosa), Toggles VoiceOver
**Priority:** P1
**Epic:** World & Narrative

## Story
As Sarah, I want room descriptions to change meaningfully with time of day and weather so that the world feels dynamic even when I return to familiar rooms — whether I'm reading visually at high contrast or listening via VoiceOver.

## Acceptance Criteria
- [ ] In-game time cycles through dawn, day, dusk, and night; each produces a distinct description variant
- [ ] Weather states (clear, cloudy, rain, fog, storm) modify room descriptions in outdoor and semi-outdoor rooms
- [ ] Time and weather are announced passively in the output stream when they change (e.g., "The light shifts. Dusk settles over the market.")
- [ ] `time` command returns current in-game time and weather in a brief, screen-reader-friendly format
- [ ] Time and weather state are shown in the persistent status region (screen-reader: `role="status"`, visual: status bar)
- [ ] Description variation is noticeable but not so different that navigation cues are lost (exit names remain consistent)
- [ ] High-contrast visual mode still reflects time/weather through CSS class changes on the room description element

## Notes
- Sarah toggles between visual and VoiceOver — both rendering paths must reflect time/weather
- High-contrast CSS must not lose time/weather context cues that sighted Sarah relies on visually
- In-game time runs faster than real time (suggested ratio: 1 real hour = 3 in-game hours) — transition announcements must not spam
- Weather in Mordoon should lean toward fog and cold rain; Rune weather is more variable
- Time/weather state is server-authoritative and shared globally — all players experience the same conditions simultaneously
