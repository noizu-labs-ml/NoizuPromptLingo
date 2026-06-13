# US-097: Streaming and Content Creation Support

**Persona:** Raj — Sighted accessible gaming content creator, YouTube/Twitch
**Priority:** P2
**Epic:** Streaming / Content Creation

## Story
As Raj, I want tools that help me produce accessible streaming content — including proper audio routing so my screen reader narration and game audio are captured correctly — so that my audience can experience the game authentically through my streams.

## Acceptance Criteria
- [ ] Game audio channels (ambient, effects, music) are exposed as separate virtual audio outputs compatible with OBS audio routing
- [ ] A "Streamer Mode" setting suppresses: account name from game output, party member real names (shows character names only), and any PII in system messages
- [ ] Game provides a "Now Playing" overlay-compatible API endpoint returning: current zone, active quest name, character name and level — suitable for stream overlay widgets
- [ ] Chat log can be exported per-session as plain text for video captions/descriptions
- [ ] A "Screen Reader Audio" channel option allows screen reader TTS to be routed to a dedicated audio channel for capture
- [ ] Streamer Mode persists until explicitly disabled

## Notes
Raj streams gameplay where a blind player (often a guest) uses NVDA or VoiceOver while Raj provides sighted commentary. The screen reader audio routing is the key technical differentiator — without it, the screen reader voice bleeds into game audio uncontrollably. This likely requires OS-level virtual audio device documentation, not just in-game settings.
