---
id: US-048
title: "Appeal a Rejected Site Submission"
slug: "appeal-rejected-site"
personas: [P-002, P-008]
epic: "Moderation & Review"
priority: "should-have"
complexity: "M"
tags: [moderation, appeal, dispute, fairness]
---

# US-048: Appeal a Rejected Site Submission

## User Story

**As an** indie web developer (P-002),
**I want to** formally appeal a rejection I believe was made in error,
**So that** I have a fair path to reconsideration without simply resubmitting the same site.

## Acceptance Criteria

- [ ] Given my submission was rejected, when I view the rejection detail (US-028), then I see an "Appeal This Decision" option available for 14 days after rejection
- [ ] Given I initiate an appeal, when the appeal form opens, then I can provide a written argument (up to 500 characters) explaining why I believe the rejection criteria were misapplied, and optionally link to specific site sections as evidence
- [ ] Given I submit an appeal, when it is received, then it enters a dedicated appeal queue visible in the moderator dashboard (US-046) and I see an expected response time of 5 business days
- [ ] Given a moderator reviews my appeal, when they reach a decision, then I am notified by email: if overturned, the site is listed; if upheld, the appeal is closed with the moderator's written rationale and the 14-day window is reset only after a 90-day waiting period

## Notes

Appeals are limited to one per submission — a user cannot appeal an upheld appeal. The 90-day cooling period after an upheld appeal prevents appeal spam. Appeals that are overturned feed data into score recalibration (US-050) as evidence of scoring model drift.
