# US-060: Short Session Narrative Continuity

**Persona:** Lena — Sighted Tabletop RPG Player / English Teacher
**Priority:** P1
**Epic:** Quest & Narrative

## Story
As Lena, I want the game to re-orient me quickly when I return after a short absence so that I can play in 30–45 minute sessions without spending the first 10 minutes piecing together where I left off.

## Acceptance Criteria
- [ ] On login, a `recap` is automatically presented: current location, active quest hooks (brief), last NPC interacted with, and any world events that occurred since last session
- [ ] Recap is written in the game's narrative voice — not a system dump of state fields
- [ ] `recap` command can be re-issued at any time during a session for a refresher
- [ ] Active quest hooks in recap include the last action taken and the next known path forward (without giving away solutions)
- [ ] If significant world events occurred since last login (NPC died, world event fired), these are noted in the recap first
- [ ] Recap length is bounded: < 150 words by default; `recap full` provides extended detail
- [ ] Players can annotate their own notes via `note <text>` and surface them in the next session's recap under "Your notes"
- [ ] Recap is accessible to screen readers: structured as a flat list of categories, not prose paragraphs that require skimming

## Notes
- Lena is an English teacher; the narrative recap must read well — this is a quality signal for her
- "Your notes" feature is for players who want to journal their play — Lena uses tabletop session notes and will appreciate this
- Recap generation can be AI-assisted but must be templated enough to be reliable — session continuity is not the place for narrative experimentation
- Screen reader structure: use headings (`h3`) for each recap category so screen reader users can jump to the relevant section
- Recap should NOT spoil world events that the player hasn't yet encountered in-world — only surface events that have definitively reached them
