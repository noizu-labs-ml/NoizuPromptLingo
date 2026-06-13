---
id: US-030
title: "Enforce Submission Limits by Plan Tier"
slug: "submission-limits"
personas: [P-002, P-008, P-006]
epic: "Site Submission"
priority: "must-have"
complexity: "M"
tags: [submission, monetization, limits, freemium]
---

# US-030: Enforce Submission Limits by Plan Tier

## User Story

**As a** community curator (P-008),
**I want to** understand my submission quota and upgrade easily when I hit it,
**So that** I can plan my discovery contributions without being unexpectedly blocked.

## Acceptance Criteria

- [ ] Given I am on a free plan, when I view the submission form, then I see a clear indicator showing remaining submissions this month (e.g., "2 of 3 remaining")
- [ ] Given a free-plan user has used all 3 monthly submissions, when they attempt a new submission, then they see a paywall prompt explaining the paid plan's unlimited submissions
- [ ] Given I am on a paid plan, when I submit sites, then no monthly cap is enforced and no quota indicator is shown
- [ ] Given my monthly quota resets, when the calendar month rolls over, then my remaining count returns to 3 and I am not notified unless I had been blocked previously

## Notes

Quota state must be checked server-side to prevent client-side circumvention. Upgrade path links to the monetization/pricing page. Bulk submission for power users is US-031.
