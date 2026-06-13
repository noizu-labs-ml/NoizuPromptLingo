---
id: US-036
title: "View Competition Entry Status"
slug: "view-entry-status"
personas: [P-001, P-002, P-004]
epic: "Competition Entry"
priority: "must-have"
complexity: "S"
tags: [competitions, entry, status, dashboard, tracking]
---

# US-036: View Competition Entry Status

## User Story

**As a** blogger who has entered a competition (P-004),
**I want to** view the current status of my competition entry,
**So that** I know whether I'm still in the running and can see my current position as scoring progresses.

## Acceptance Criteria

- [ ] Given I have entered one or more competitions, when I visit my dashboard, then I see an "Active Competition Entries" section listing each entry with its status (Pending, Scoring, Live, Closed), competition name, and time remaining
- [ ] Given I click on a competition entry, when the entry detail view loads, then I see my entry's confirmation number, submitted posts, current AI scores, and my current rank among all entries
- [ ] Given the competition is in scoring phase, when I view my entry, then I see a scoring progress indicator (e.g., "AI scoring in progress — results in ~2 hours")
- [ ] Given the competition has closed and results are finalized, when I view my entry, then I see my final rank, percentile, and a comparison of my scores vs. the winner's scores
- [ ] Given I placed in the top 3, when I view my entry status, then a winner badge or medal icon is displayed with a share prompt for social media
- [ ] Given I want to revisit past competition entries, when I navigate to Competition History in my profile, then I see all past entries sorted by most recent with final ranks

## Notes

Entry status tracking is a key retention mechanism — it brings bloggers back to the platform after submission. Push or email notifications when scoring completes would complement this story. Related to US-035 (submission), US-037 (withdraw), US-044 (host closes and finalizes).
