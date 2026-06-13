# US-043: Rune City District Navigation

**Persona:** Elena — Blind Teenager (16), VoiceOver on iPhone
**Priority:** P1
**Epic:** World & Exploration

## Story
As Elena, I want to navigate Rune's districts using named landmarks and district commands so that I can find my way around the starter city without needing a visual map or sighted assistance.

## Acceptance Criteria
- [ ] `districts` command lists all Rune districts with a one-line description each
- [ ] `go <district>` fast-travels to the district entrance (with confirmation of travel time/steps)
- [ ] Each district entrance room includes a `landmarks` command listing named points of interest within that district
- [ ] `go <landmark>` navigates to a known landmark within the current district
- [ ] Room descriptions in Rune reference adjacent district transitions ("the smell of the harbor market drifts from the east")
- [ ] First-time entry to any district triggers a brief orientation message (suppressible via `/set first-visit-hints off`)
- [ ] `whereis` command outputs: current room name, current district, nearest landmark, available exits

## Notes
- Elena plays on iPhone with VoiceOver; touch-friendly command aliases (short, memorable) are essential
- District list for Rune (v1): Market Quarter, Harbor Docks, Scholar's Row, Temple District, Outer Wall, The Tangle (slums)
- Landmark names must be pronounceable by VoiceOver without phonetic mangling — avoid abbreviations
- "go" command should provide estimated step count for players who want spatial orientation
- This story pairs with US-044 (Mordoon navigation) — shared navigation API, different datasets
