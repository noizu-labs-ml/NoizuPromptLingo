---
id: US-044
title: "Close Competition and Finalize Results"
slug: "close-competition-and-finalize-results"
personas: [P-005, P-008]
epic: "Competition Hosting"
priority: "must-have"
complexity: "L"
tags: [competitions, hosting, close, results, finalization, scoring]
---

# US-044: Close Competition and Finalize Results

## User Story

**As a** competition host (P-005),
**I want to** close my competition and finalize the AI-scored results,
**So that** I can declare winners, celebrate participants, and provide a definitive outcome that builds credibility for future competitions I host.

## Acceptance Criteria

- [ ] Given a competition's deadline has passed, when the system auto-closes the entry window, then the competition status updates to "Scoring" and no new entries can be submitted
- [ ] Given the competition is in "Scoring" status, when the AI scoring pipeline completes for all entries, then the competition transitions to "Results Ready" and the host is notified via email
- [ ] Given results are ready, when I (as host) navigate to the competition management page, then I see a ranked leaderboard of all entries sorted by weighted AI score and a "Finalize Results" button
- [ ] Given I click "Finalize Results," when I confirm, then the competition transitions to "Closed" status, the public competition page updates to show the final ranked results, and all entrants receive results notifications
- [ ] Given the competition is finalized, when entrants view the competition page, then the top 3 winners are displayed with podium styling and all participants see their final rank and percentile
- [ ] Given I as host want to manually close a competition early, when I navigate to competition settings and click "Close Early," then I can end the entry period before the deadline with a required reason that is shown on the competition page

## Notes

Auto-close on deadline is required; manual early close is optional override. Scoring pipeline duration depends on entry count — estimate displayed to host. Finalization emails to all entrants are the primary re-engagement moment. Related to US-041 (deadline settings), US-043 (manage entries), US-036 (entrant sees results), US-047 (leaderboard reflects competition results).
