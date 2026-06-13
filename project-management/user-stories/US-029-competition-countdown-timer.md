---
id: US-029
title: "Competition Countdown Timer"
slug: "competition-countdown-timer"
personas: [P-001, P-004, P-005]
epic: "Competition Browsing"
priority: "should-have"
complexity: "S"
tags: [competitions, countdown, urgency, timer, ui]
---

# US-029: Competition Countdown Timer

## User Story

**As a** blogger browsing open competitions (P-001),
**I want to** see a live countdown timer showing time remaining until a competition closes,
**So that** I can feel the urgency and plan my entry before the deadline passes.

## Acceptance Criteria

- [ ] Given an open competition has a closing deadline, when I view the competition card or detail page, then a live countdown displays days, hours, minutes, and seconds remaining
- [ ] Given a competition has more than 7 days remaining, when the timer is shown, then it displays in a neutral style (e.g., gray or brand color)
- [ ] Given a competition has 24 hours or fewer remaining, when the timer is shown, then it pulses or uses a warning color (amber/red) to signal urgency
- [ ] Given a competition deadline passes while I am viewing the page, when the countdown reaches zero, then the UI updates to show "Competition Closed" without requiring a page refresh
- [ ] Given an upcoming competition has not yet started, when I view its card, then a "Starts in" countdown is shown instead of a closing deadline
- [ ] Given the user's browser timezone differs from the server timezone, when deadlines are displayed, then they are shown in the user's local timezone with a tooltip showing UTC

## Notes

Uses client-side JavaScript with server-synced deadline timestamps. Timer should be accessible (ARIA live region for screen readers). Related to US-028 (competition details) and US-044 (host closes competition). The competition host persona P-005 also benefits from this for monitoring entry windows.
