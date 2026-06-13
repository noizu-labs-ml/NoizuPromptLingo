---
id: US-066
title: "Analytics Empty State for New Blogs"
slug: "analytics-empty-state"
personas: [P-004, P-001]
epic: "Analytics Dashboard"
priority: "should-have"
complexity: "S"
tags: [analytics, empty-state, onboarding, new-user, ux]
---

# US-066: Analytics Empty State for New Blogs

## User Story

**As a** new blogger (P-004),
**I want to** see a clear and encouraging empty state when I first visit analytics before my blog has been scored,
**So that** I understand what's coming and what I need to do to unlock the analytics dashboard.

## Acceptance Criteria

- [ ] Given I have submitted a blog but have not yet received a first AI score, when I visit /dashboard/analytics, then I see an empty state with an illustration and the message "Your analytics will appear after your first AI score"
- [ ] Given the empty state renders, when I view it, then it includes a CTA: "Check scoring status" linking to my submission status page
- [ ] Given my blog has received one score but not yet a second, when I visit /dashboard/analytics, then a partial empty state shows my current scores but the trend chart displays a message: "Trend data appears after your second scoring event"
- [ ] Given I have received at least 2 scoring events, when I visit /dashboard/analytics, then the full analytics dashboard renders with no empty state messaging
- [ ] Given the empty state is displayed, when I am on a Free tier account, then the empty state also surfaces a gentle mention of Pro analytics features to prime future upgrade intent

## Notes

Two distinct empty sub-states: pre-first-score and post-first-score/pre-second-score. The partial state (one score) is important — don't block all value delivery just because trends aren't possible yet. Show radar chart even with one score. See US-059 for trend chart, US-060 for radar chart.
