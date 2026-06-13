---
id: US-018
title: "Request Blog Re-Index"
slug: "reindex-request"
personas: [P-001, P-002, P-007]
epic: "Blog Indexing & Scoring"
priority: "should-have"
complexity: "S"
tags: [indexing, reindex, refresh, scoring]
---

# US-018: Request Blog Re-Index

## User Story

**As a** blogger (P-001),
**I want to** manually trigger a re-index of my blog,
**So that** my score reflects newly published posts and content improvements I've made since the last crawl.

## Acceptance Criteria

- [ ] Given my blog has been indexed at least once, when I view my blog settings, then I see a "Re-index now" button with the timestamp of the last index
- [ ] Given I click "Re-index now", when I am on the Free tier, then I am told re-indexing runs automatically every 14 days and I must upgrade to Pro for manual re-indexing; a "Remind me in 3 days" option is offered
- [ ] Given I click "Re-index now", when I am on the Pro tier, then a re-index job is queued and I see the progress indicator (US-017); this can be triggered at most once every 24 hours
- [ ] Given I click "Re-index now", when I am on the Team tier, then a re-index job is queued with higher priority and can be triggered at most once every 6 hours
- [ ] Given a re-index completes, when the new scores differ from the previous scores, then a score change notification is shown in the dashboard (e.g., "+3.2 Writing Quality since last index")

## Notes

Automatic re-indexing schedule: Free = every 14 days, Pro = every 7 days, Team = every 3 days. Re-index should not overwrite the score history record — a new score snapshot should be appended (US-019). Related: US-015 (scoring), US-019 (score history).
