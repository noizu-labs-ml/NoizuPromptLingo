# US-239: Instanced Zones

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Dave, I want boss chambers and personal quest climaxes to be instanced per player or party so that my experience isn't disrupted by other players and the story beats feel genuinely personal rather than shared.

## Acceptance Criteria
- [ ] Instance creation transparent to player: entering an instanced zone triggers a brief transition narration ("The door responds to your presence alone — you step through into a space that feels sealed off from the world") without exposing the server mechanism
- [ ] Solo instances created for personal quest climaxes, story revelation chambers, and player housing; party instances created for boss encounters and shared quest content
- [ ] Instance entry from party: party leader triggers instance creation; party members join via a shared portal or simultaneous entry; latecomers can join until a configurable lockout point
- [ ] Instance state fully persistent for the player's active session: re-entering an abandoned instance resumes exactly where it was left, including combat state, puzzle state, and NPC positions
- [ ] Instance expiry communicated proactively: "This instance will expire in 30 minutes if no players remain" — announced when last player exits; on re-entry after near-expiry a warning is shown
- [ ] Performance: instance creation must complete within 2 seconds of player trigger; instance state managed by a dedicated OTP process per instance with garbage collection on expiry
- [ ] Instance-exclusive content: boss loot tables and story revelations are instance-private; no kill-stealing or loot contention from other players
- [ ] Shared world context maintained: instanced zones exist within the shared world timeline; events inside an instance can affect the shared world (completing a story instance may trigger a shared world event announcement)

## Notes
Dave's sysadmin perspective means he'll appreciate transparent instance management and be frustrated by visible seams (lag on entry, visible "instance N" labels in room names, inconsistent state on re-entry). The OTP process-per-instance model is the natural Phoenix/Elixir implementation: each instance is a GenServer with its own state, supervised and garbage-collected when empty and expired. The 2-second creation time is a hard requirement — players should not feel a loading screen. The "sealed off" transition narration is the fiction layer that makes instance entry feel like part of the game world rather than a technical system. Party instancing requires careful synchronization: when Tyler's clan enters a boss chamber together, all party members should see the same state. The shared world consequence of instance completion (completing a story instance triggers a public announcement) is the social layer: Dave's private story moment can have world-visible effects, which other players will notice and ask about. Instance-exclusive loot is the justification for instancing in PvP contexts: Tyler's clan can kill a boss without Tyler or Dave stealing loot from each other. Re-entry state persistence is critical for Lena's short sessions: she should be able to close the browser mid-boss-fight and return to the same fight state within a reasonable expiry window.
