---
id: US-064
title: "Report a Comment"
slug: "report-a-comment"
personas: [P-002, P-004, P-008]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "S"
tags: [moderation, reporting, comments, safety]
---

# US-064: Report a Comment

## User Story

**As an** AI hobbyist (P-002),
**I want to** report a comment that violates community guidelines,
**So that** moderators can review and remove abusive or harmful replies.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing a comment, when I click the comment's "Report" option (via dropdown or context menu), then I see a report reason modal
- [ ] Given I submit a comment report, when it is received, then it appears in the moderator queue (US-065) associated with the specific comment and thread context
- [ ] Given a comment I reported is removed by a moderator, when I return to the thread, then the comment is replaced with a "removed" placeholder
- [ ] Given I am not authenticated, when I attempt to report a comment, then I am redirected to the login page

## Notes

Mirrors the prompt reporting flow (US-063) but scoped to comments. The report reason options should be identical for consistency. Consider a lightweight inline design (no full-page redirect) to minimize friction.
