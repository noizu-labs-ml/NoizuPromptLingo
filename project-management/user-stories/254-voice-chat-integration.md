# US-254: Voice Chat Integration

**Persona:** Raj — Content creator and streamer who wants to offer richer party experiences for his audience
**Priority:** P2
**Epic:** Advanced Social & Governance

## Story
As Raj, I want optional WebRTC voice channels for parties and clans so that I can provide richer streaming content and coordinate with teammates in real-time, while ensuring that every piece of game information remains available as text for blind players and for my stream's accessibility.

## Acceptance Criteria
- [ ] Voice channels are opt-in per player and per session; players without voice enabled (or without microphone) participate fully in all game activities; voice is supplemental, never a requirement for game progression or social participation
- [ ] Voice is available in three scopes: Party voice (auto-created with party), Clan voice (persistent, always available to clan members), and Event voice (created by event organizer, see US-246); each is a separate channel
- [ ] All information conveyed via voice must also be conveyed via text — game mechanics, NPC dialogue, combat narration, and system messages are never voice-only; voice is a communication channel between players, not a game information delivery mechanism
- [ ] Voice controls accessible via keyboard: `/voice join [party|clan|event]`, `/voice leave`, `/voice mute [self|player]`, `/voice volume [0-100]`; all controls functional without mouse; current voice status readable via `/voice status` (lists: joined channel, who is speaking, who is muted)
- [ ] Speaker indication: when a player speaks in voice, a text notification appears in the relevant channel: "[Player] is speaking" — this is the voice-to-text bridge for deaf/hard-of-hearing players and for screen readers; configurable to show/hide via `/voice settings speaker-indicator [on|off]`
- [ ] Stream-friendly design: Raj can set his party voice to "broadcast mode" where he is the only speaking voice (others are muted for his stream), but all typed text remains two-way; this prevents involuntary broadcasting of other players' voices
- [ ] Privacy: voice conversations are not recorded by the server; no transcript is stored; players are notified when joining a voice channel that it is not monitored; in-game abuse reports for voice interactions require player to submit a timestamped incident report (no automatic audio evidence)
- [ ] Voice is disabled by default and must be enabled explicitly in settings; voice-enabled status is not visible to other players (no indicator that a player has voice capability); this prevents social pressure to enable voice

## Notes
The key design principle: voice is a convenience, not an architecture. The game was designed for screen readers as the primary rendering engine. Voice is a social overlay for players who want it, not a communication system that game mechanics depend on. This means the implementation can be relatively thin — WebRTC for transport, Phoenix Channels for signaling, client-side audio — without deep integration into the game engine.

The "all game information must be available as text" requirement is an architectural constraint, not a feature. Every announcement, NPC line, combat result, and system message must have a text representation in ARIA live regions. Voice does not carry any of this — only player-to-player conversation.

The speaker indicator text notification is the critical bridge. When Marcus (who doesn't use voice) is in a party with Raj and Tyler who are on voice, Marcus needs to know when his teammates are communicating, even if he can't hear them. The "[Player] is speaking" indicator tells him "there's coordination happening; I should pay attention to what follows in text." It's an imperfect bridge but it's the right bridge.

The privacy model (no server recording, no automatic evidence) is a deliberate choice. Requiring server-side recording to support abuse reports creates a mass surveillance infrastructure and enormous storage costs. The tradeoff is that voice abuse is harder to prove. The mitigation: voice abuse should be treated as a community standards violation reportable via the conduct system, with the understanding that evidence burden differs from text abuse. Voice abuse that escalates to conduct violations can result in voice privilege suspension.

Raj's broadcast mode requirement is real. Streamers cannot broadcast other players' unvetted audio — it creates legal and community issues. The opt-in broadcast mode (he mutes all others in his stream, while they continue hearing him if they're on voice) is a clean solution. Alternatively, Raj can simply use an external Discord/voice tool for streaming and keep the in-game voice for private party coordination.

For V1: implement Party and Clan voice only. Event voice adds complexity (dynamic channel creation/destruction) and can ship in V2 once the core infrastructure is stable.
