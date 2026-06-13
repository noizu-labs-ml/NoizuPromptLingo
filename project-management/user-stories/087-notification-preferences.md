# US-087: Notification Preferences

**Persona:** Lena — Sighted tabletop RPG player, English teacher, short sessions
**Priority:** P1
**Epic:** Settings

## Story
As Lena, I want to configure which game events trigger notifications and how they are delivered so that I can stay informed between short play sessions without being overwhelmed by interruptions.

## Acceptance Criteria
- [ ] Notification categories are independently toggleable: party events, direct messages, auction/trade alerts, world events, system messages
- [ ] Delivery method per category: in-game only, browser push notification, email digest (daily/weekly)
- [ ] Browser push notifications require explicit opt-in permission request with plain-language explanation
- [ ] Email digest settings link to an unsubscribe mechanism reachable without logging in
- [ ] "Do Not Disturb" mode suppresses all in-game notifications for a configurable duration (15min, 1hr, until I turn it off)
- [ ] Notification history log is accessible via `/notifications` command or settings panel
- [ ] All notification UI elements are keyboard navigable and screen-reader compatible

## Notes
Lena plays in 20–30 minute windows between grading sessions. Push notifications for party readiness or auction closure help her stay engaged without leaving the game open. DND mode is important for classroom hours.
