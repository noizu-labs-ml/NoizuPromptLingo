---
id: US-036
title: "Engagement History"
slug: "engagement-history"
personas: [P-007, P-002, P-006]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "M"
tags: [dashboard, history, engagements, archive]
---

# US-036: Engagement History

## User Story

**As a** returning client with multiple past engagements (P-007),
**I want to** view a historical record of all past projects and engagements with Keith,
**So that** I can reference prior work, retrieve old deliverables, and provide context when starting a new engagement.

## Acceptance Criteria

- [ ] Given I navigate to the Engagement History section, when the page loads, then I see a list of all past (completed or closed) projects sorted by end date descending
- [ ] Given I click on a past engagement, when the detail page loads, then I can view milestones, deliverables, and documents from that engagement in read-only mode
- [ ] Given a past engagement has deliverables, when I view the engagement detail, then I can still download those deliverables
- [ ] Given I have both active and past engagements, when I view the dashboard, then active and past engagements are clearly separated
- [ ] Given I want to reference a past engagement when creating a support ticket, when I compose the ticket, then I can link it to a historical engagement

## Notes

Read-only access to historical data. Useful for clients who return after a gap — they can self-serve context. Enterprise procurement (P-006) may need this for vendor records/audit trails. Archive view should include: engagement type, start/end date, summary, final status, and deliverables. Consider a "start a similar engagement" CTA linking to the RFI flow.
