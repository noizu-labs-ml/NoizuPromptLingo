# US-246: Player-Run Events & Storytelling

**Persona:** Raj — Content creator who streams the game and wants tools that make compelling broadcasts
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Raj, I want accessible creator tools that let me organize tournaments, storytelling sessions, and markets so that I can produce content worth streaming and build a reputation as a community organizer within the game world.

## Acceptance Criteria
- [ ] Event creation via `/event create` opens a structured wizard: Event Name, Type (Tournament/Storytelling/Market/Custom), Description (500 chars), Start Time (in-game and real-world timestamp), Location (room selector), Entry Requirements (optional: level range, class, fee), Maximum Participants
- [ ] Created events are submitted to city bulletin board (US-248) automatically and announced via city-wide ARIA live region broadcast with event name, creator, type, time, and location
- [ ] Event creator gains a private event management panel accessible via `/event manage [id]`; panel shows: participant list (navigable), countdown to start, controls to Start, Pause, End, or Cancel the event
- [ ] Tournament bracket system supports single-elimination and round-robin formats; bracket state narrated as: "Round 2, Match 3: Marcus vs. Tyler. Tyler advances after a narrow victory. Next match in 5 minutes."
- [ ] Storytelling events support a stage channel where the event creator (narrator) has elevated broadcast priority — their narration appears before room descriptions, formatted distinctly (e.g., prefixed with "The Narrator says:")
- [ ] Market events create temporary vendor stalls: participating players register stalls with item listings visible to browsers via `/market browse [event-id]`; browsable as accessible list with item name, quantity, price, seller name
- [ ] Event results are automatically recorded: winner (for tournaments), item totals traded (for markets), attendee count; posted to event's bulletin board listing as a post-event summary
- [ ] Streaming-friendly: `/event spectate [id]` command allows non-participants to receive all event narration without entering the physical room, up to a configurable spectator cap; spectators cannot interact with event

## Notes
Raj's value to the game is as an amplifier — his streams bring in new players. The event tools need to produce content that is compelling to watch as a stream. That means clear narrative structure (brackets are readable, market results are tallied, tournament outcomes are dramatic), pacing controls (the creator can pause between rounds), and spectator infrastructure.

The spectator mode is key for streaming: Raj can be in a separate "director's" location while streaming the event narration to his audience, without physically crowding the event space. Spectator cap prevents server overload from viral events; configurable up to 200 by default.

Accessibility for event creation: the event wizard must be completable without a mouse. Each field should have clear focus management — after completing a field and pressing Tab, focus moves to the next field, not to a submit button. The room selector for location should be a searchable list of accessible room IDs, not a graphical map picker.

The "elevated broadcast priority" for storytelling narrators requires careful ARIA design. The narrator's text should use `aria-live="assertive"` rather than `"polite"` so it interrupts other announcements, but only narrator-originated text should use this priority — other room activity remains polite. This prevents audio chaos for screen reader users.

Anti-grief: event creators can mute participants from their management panel. Participants who grief a player-run event (spamming, interrupting with PvP attacks in a safe zone) can be reported via the event panel; GMs receive flagged event transcripts for review. Consider a "safe event zone" toggle that temporarily makes the event location a no-PvP room for the event duration.

For Raj specifically: the game should have a way to mark a character as a "public broadcaster" — their in-game handle shows as a stream link on their profile, and event result summaries include a note that the event was organized by a known streamer. This drives discovery.
