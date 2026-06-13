# US-079: Social Moderation Tools for Players and Moderators

**Persona:** Priya — Sighted Accessibility Engineer
**Priority:** P0
**Epic:** Social Moderation

## Story
As Priya, I want robust player-facing and moderator moderation tools so that harassment is actionable, reports are accessible to file, and the moderation workflow itself does not create accessibility barriers for reporters or moderators.

## Acceptance Criteria
- [ ] `REPORT [player] [reason]` submits a report with automatic context capture (last 20 lines of chat, location, timestamp) — no manual evidence collection required
- [ ] Report confirmation is announced immediately: "Report submitted. Reference: #4821. A moderator will review within 24 hours."
- [ ] Moderator dashboard is keyboard-navigable with screen reader support: report queue as a list, each item focusable with full context accessible
- [ ] Moderators can apply: warning, mute (duration), chat restriction, account suspension — all with templated reason text sent to the reported player
- [ ] Sanctioned players receive accessible notification of action taken and appeals process
- [ ] Appeals are filed via `APPEAL [report-id]` with a text field for additional context
- [ ] All moderation actions are logged with moderator ID, timestamp, and reason — auditable by senior moderators

## Notes
Priya will test this with every major screen reader. The report flow must be operable in under 5 keystrokes from any game context. Moderator tools should be built as accessible web admin, not a bespoke in-game interface — a Next.js admin panel with full ARIA compliance. Auto-capture of context prevents the burden falling on distressed reporters.
