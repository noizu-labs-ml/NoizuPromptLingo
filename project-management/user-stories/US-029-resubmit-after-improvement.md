---
id: US-029
title: "Resubmit a Site After Improvement"
slug: "resubmit-after-improvement"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "must-have"
complexity: "S"
tags: [submission, resubmission, iteration]
---

# US-029: Resubmit a Site After Improvement

## User Story

**As an** indie web developer (P-002),
**I want to** resubmit a previously rejected URL after making improvements,
**So that** my site gets a fresh evaluation reflecting the work I have done.

## Acceptance Criteria

- [ ] Given my submission was rejected, when I click "Resubmit," then the form is pre-filled with my original URL and previously suggested category
- [ ] Given I resubmit a URL, when the system processes it, then a fresh AI score is computed rather than using cached scores from the prior attempt
- [ ] Given I am on a free plan, when I resubmit, then the resubmission counts against my monthly submission quota per US-030
- [ ] Given a site has been rejected more than three times, when I attempt to resubmit, then I see a notice indicating a mandatory 30-day cooldown period

## Notes

Cooldown rules prevent gaming the scoring system through rapid iteration. Rejection feedback leading here is US-028; submission limits are US-030.
