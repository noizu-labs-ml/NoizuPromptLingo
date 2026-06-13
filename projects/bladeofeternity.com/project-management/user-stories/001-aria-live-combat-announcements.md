# US-001: ARIA Live Region Announcements for Combat Events

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want combat events (attacks, damage, status effects, kills) announced through ARIA live regions so that I can follow fast-paced PvP combat without missing critical information.

## Acceptance Criteria
- [ ] A `role="log"` live region with `aria-live="polite"` announces standard combat events (hits, misses, damage numbers) without interrupting current speech
- [ ] A secondary `aria-live="assertive"` region announces critical events (near-death, crowd control, kill confirmation) immediately, interrupting polite announcements
- [ ] Each announcement is atomic and complete (e.g., "You strike Vareth for 142 shadow damage. Vareth is stunned.") — no fragmented multi-part messages
- [ ] Announcements are throttled/batched during AoE combat to prevent speech queue overflow (no more than 3 messages per second delivered to assertive region)
- [ ] Players can configure announcement verbosity: Full / Summary / Critical-only
- [ ] Live region content is cleared after announcement to prevent re-reading on focus

## Notes
NVDA on Firefox has known quirks with rapid live region updates — test with 200ms minimum gap between assertive injections. Consider a separate `aria-live="off"` buffer region that gets toggled to `assertive` per message to force re-announcement of identical strings (e.g., repeated "Miss" events).
