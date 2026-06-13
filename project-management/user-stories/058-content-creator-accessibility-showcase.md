# US-058: Content Creator Accessibility Showcase

**Persona:** Raj — Sighted Accessible Gaming Content Creator
**Priority:** P2
**Epic:** Community & Outreach

## Story
As Raj, I want the game to provide a structured way to demonstrate its accessibility features on stream so that I can showcase how a text MMORPG can be a first-class experience for blind players, growing both the game's audience and awareness of accessible gaming.

## Acceptance Criteria
- [ ] A `/demo` command sequence exists that walks through: room navigation, examine, NPC dialogue, quest hook, and map aid — in a controlled demonstration environment
- [ ] Demo mode runs in a sandboxed world state so that streamer actions don't affect the live world
- [ ] All screen reader announcements during demo are audible in stream capture (no OS-level audio routing issues)
- [ ] The game has a publicly accessible "how it works for blind players" page linked from the main site
- [ ] `accessibility` command in-game outputs a brief, linkable summary of screen reader support and commands
- [ ] The game's command vocabulary is documented in a publicly available quick-reference card (text format, screen-reader navigable)
- [ ] Raj can invite a blind player collaborator to the demo world for a live co-play demonstration

## Notes
- Raj's content has significant reach in accessible gaming communities — this is a meaningful marketing channel
- Demo mode must look compelling even when Raj is narrating for a sighted audience who may never have seen a text game
- Audio routing: VoiceOver system audio must be capturable via OBS without additional configuration — test on macOS streaming setup
- The "how it works" page should feature actual screen reader output recordings, not just text descriptions
- Co-play in demo world requires a two-player demo environment — both players in the same sandboxed session
