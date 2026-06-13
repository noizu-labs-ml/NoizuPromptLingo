# US-021: PvP Duel Initiation and Consent Flow

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Combat — PvP

## Story
As Marcus, I want to challenge another player to a duel and receive an audible, non-interruptive consent prompt so that I can engage in consensual PvP without disrupting my screen reader's reading queue.

## Acceptance Criteria
- [ ] Duel challenge command available via keyboard shortcut and command input (`/duel <player>`)
- [ ] Challenge notification delivered to target via ARIA live region with `aria-live="polite"` to avoid interrupting current narration
- [ ] Target receives: challenger name, duel type (standard/ranked/first-blood), and accept/decline action buttons reachable by Tab
- [ ] Acceptance confirmation announced in both players' assertive live regions simultaneously
- [ ] Duel start sequence narrated with combatant names, location, and initial stance descriptions
- [ ] Duel can be initiated with `aria-describedby` linking challenge button to rules summary
- [ ] Timeout (60 seconds) on unanswered challenge; both parties notified via polite region

## Notes
Screen reader announcement ordering matters: challenge must not clobber active combat narration. Use polite region for challenge; switch to assertive only on duel start. Consider a dedicated "PvP tray" ARIA landmark for pending challenges so Marcus can navigate to it without losing his place in the main feed.
