# US-251: Social Emote System

**Persona:** Elena — Blind teenager for whom emotional and social expression is core to the experience
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Elena, I want a rich set of expressive social actions that are narrated in vivid third-person prose so that I can communicate emotion and personality without relying on emoji or visual gestures, and so that everyone in the room experiences my expressions equally.

## Acceptance Criteria
- [ ] Core emote library of at least 40 emotes covering: greetings (wave, bow, curtsey, nod), positive emotion (laugh, cheer, dance, smile), negative emotion (frown, sigh, sulk, shake head), social bonding (hug, pat, high-five, salute), and roleplay (ponder, examine, shrug, stretch)
- [ ] Emotes produce third-person narration in the room channel: `[Player] waves cheerfully at the assembled company.`; targeted emotes include target name: `[Player] bows deeply before [Target], a gesture of profound respect.`; narration varies with 2–3 alternates per emote to prevent repetition
- [ ] Emotes are invoked via `/emote [name]` or `:[name]` shorthand; targeted emotes via `/emote [name] [player]` or `:[name] [player]`; tab-completion on emote names reduces typing burden
- [ ] Accessible emote picker: `/emote list` presents all emotes as a flat alphabetical list, navigable by arrow keys; each emote entry reads: emote name, example output; filter by category: `/emote list greetings`
- [ ] Context-aware description modifiers: emote descriptions adapt to character state — a laughing character who is injured narrates: "[Player] winces through a laugh, hand pressed to their side."; state flags (injured, drunk, exhausted, triumphant) modify emote prose
- [ ] Custom emote suffix: players can append a brief custom text to any emote via `/emote [name] "[custom suffix]"`; example: `/emote bow "in honor of the fallen"` produces "[Player] bows deeply, in honor of the fallen."; suffix limited to 60 chars, filtered through content moderation
- [ ] Emote history accessible via `/emote history [room]`; returns the last 20 emotes performed in the current room with timestamps; useful for reviewing social context after joining a room mid-conversation
- [ ] Emote muting: players can mute emotes from specific players via `/emote mute [player]`; muted player's emotes are suppressed from their feed; accessible via `/emote muted` list with unmute option

## Notes
The emote system's quality hinges entirely on the prose. A flat "`[Player] waves.`" is nothing. "`[Player] raises a hand in a warm, unhurried wave.`" is character. The writing investment in 40 emotes × 3 alternates × context modifiers is substantial but irreplaceable — this is where the game's voice lives in social interaction.

Elena uses VoiceOver on iOS, which means the emote shorthand (`:bow`) is accessible via the standard text input. The picker is the fallback for discovering emotes she doesn't know the name of. The picker must scroll as a flat list — no nested categories, no expandable sections — because VoiceOver's list navigation is cleanest on flat structures.

Context-aware modifiers require the emote system to query character state at execution time. The state flags to support at V1: injured (HP below 30%), drunk (intoxicated status effect), exhausted (stamina below 20%), triumphant (recently won a combat encounter), grieving (partner/friend recently died in-game). The emotional modifier system creates organic RP texture without requiring players to manually describe their character's state.

The custom suffix is a powerful roleplay tool — it lets players make any emote specific to the moment without requiring a full custom emote library. The 60-character limit keeps it brief; content moderation filters prevent abuse. The suffix should be presented in the narration as a natural extension of the emote sentence, not as a parenthetical.

Emote muting is a critical accessibility and comfort feature. Players who find certain other players' emote spam disruptive should have a lightweight way to silence them without blocking all communication. The mute list should be persistent across sessions and easily reviewable.

For future consideration: emote reactions — pressing a keyboard shortcut to attach a simple reaction (applause, laughter, sympathy) to a recent emote performed by another player; these aggregate and are periodically narrated: "[Player]'s bow was met with warm applause from the assembled company." This creates social feedback without requiring every player to compose a response.
