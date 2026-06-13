# US-035: Ranked PvP Match System — Rating, Queue, and Result Communication

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Combat — PvP

## Story
As Marcus, I want a ranked PvP queue system that communicates my rating, queue status, and match results through audible, non-interruptive announcements so that I can compete seriously without missing queue pops or rating changes.

## Acceptance Criteria
- [ ] Ranked queue entry via command or menu; current rating and rank tier announced on queue join
- [ ] Queue position/estimated wait not required — instead: "Searching for a worthy opponent..." with active status landmark
- [ ] Match found announced via assertive live region with a 30-second accept window and prominent Accept/Decline buttons
- [ ] Rating communicated in both numeric (1,847) and tier prose (Gold — Second Flight)
- [ ] Post-match rating change announced: "You gain 23 rating — 1,870. You remain in Gold Second Flight."
- [ ] Tier promotion/demotion narrated as a scene event, not a dry notification: "Your record speaks for itself — you've earned Silver First Flight."
- [ ] Season leaderboard accessible as a keyboard-navigable list with player name, rating, W/L record
- [ ] Match history accessible: last 20 matches with opponent name, result, rating delta, and date

## Notes
Queue pop announcements are time-critical — assertive live region is correct here. The 30-second accept window must be highly visible and screen-reader-obvious; use an `aria-live="assertive"` countdown. Rating tier names ("Gold Second Flight") should evoke the game's dark fantasy setting without being opaque to new players. Document the Elo variant used so Dave can understand the rating math.
