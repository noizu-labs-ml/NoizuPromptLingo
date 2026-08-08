---
id: US-092
title: "Announce Dashboard State Changes to Screen Readers"
slug: "screen-reader-dashboard-state-changes"
personas: [P-001]
epic: "Accessibility & Internationalization"
priority: "must-have"
complexity: "M"
tags: [accessibility, screen-reader, aria-live, dashboard]
---

# US-092: Announce Dashboard State Changes to Screen Readers

## User Story

**As** Jordan Vance, the Harness Operator (P-001),
**I want to** have dashboard state changes — a session completing, an agent erroring, a ticket updating — announced by my screen reader as they happen,
**So that** I can monitor multiple running agents without staring at the screen continuously.

## Acceptance Criteria

- [ ] Given Jordan's screen reader is active on the dashboard, when a background session transitions state (e.g., running to completed, running to failed), then an `aria-live` region announces the change, identifying which session and what happened.
- [ ] Given multiple state changes occur in quick succession, when they are announced, then they are queued so they don't talk over each other or get dropped silently.
- [ ] Given a state change was previously conveyed only by a visual indicator (e.g., a color pulse), when audited, then it now has an equivalent screen-reader announcement, leaving no state change visual-only.
- [ ] Given Jordan navigates away from the dashboard tab and returns, when the page regains focus, then no backlog of stale announcements fires all at once.

## Notes

Must-have per the epic's emphasis on assistive-tech users. Complements US-091's board-specific keyboard flow with the broader dashboard's live-region strategy.
