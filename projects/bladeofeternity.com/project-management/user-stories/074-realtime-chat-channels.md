# US-074: Real-Time Chat via Phoenix Channels

**Persona:** Elena — Blind Teenager, VoiceOver on iPhone
**Priority:** P0
**Epic:** Chat and Messaging

## Story
As Elena, I want real-time chat to be delivered as announced text via VoiceOver so that I can participate in social conversation with my sighted friends without delays or needing to manually refresh anything.

## Acceptance Criteria
- [ ] All chat channels (local, global, clan, party, whisper) deliver messages via Phoenix Channel push — no polling
- [ ] New messages are announced by VoiceOver using ARIA live regions with `aria-live="polite"` for normal chat and `aria-live="assertive"` for whispers and system alerts
- [ ] Channel switching is accessible: swipe or keyboard shortcut cycles through active channels with channel name announced
- [ ] Messages include sender name, channel tag, and content — format: "[Global] Arkhan: Anyone selling iron ingots?"
- [ ] Mobile (VoiceOver/iPhone): chat input is a standard `<input>` element reachable without custom gestures
- [ ] Chat history for each channel is scrollable/navigable with oldest-first ordering and timestamp on each message
- [ ] Muting a player or channel is accessible via `MUTE [player/channel]` and takes effect immediately

## Notes
Elena's primary social surface is chat. Latency matters — Phoenix Channels must push in under 200ms. ARIA live regions must be tuned carefully: assertive for direct mentions and whispers (interrupt), polite for general channel traffic (queue). On iOS, avoid custom JavaScript focus traps that confuse VoiceOver gesture navigation.
