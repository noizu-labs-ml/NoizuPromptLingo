---
id: US-073
title: "RFI Service Package Comparison"
slug: "rfi-service-comparison"
personas: [P-001, P-002, P-003]
epic: "RFI Dashboard"
priority: "could-have"
complexity: "M"
tags: [rfi, prospect, comparison, services, decision-support]
---

# US-073: RFI Service Package Comparison

## User Story

**As a** VP of Engineering evaluating engagement models (P-002),
**I want to** compare service packages side-by-side before submitting an RFI,
**So that** I can select the engagement type that fits my team's needs and arrive at the RFI form with a clear intent.

## Acceptance Criteria

- [ ] Given I am on the services page or the RFI landing page, when I click "Compare Services", then a comparison table is displayed with up to 4 service types as columns.
- [ ] Given the comparison table, when I view it, then each column shows: service name, engagement model (retainer/project/hourly), typical deliverables, ideal client profile, and indicative budget range.
- [ ] Given the comparison table, when I click "Select" under a service type, then I am taken to the RFI form with that service type pre-selected.
- [ ] Given I am viewing the comparison table on mobile, when the screen is narrower than 768px, then the table collapses to a swipeable card stack (one service per card).
- [ ] Given the comparison table content, when an admin updates a service description via the CMS (US-059), then the comparison table reflects the change.

## Notes

This feature reduces RFI form abandonment by helping undecided prospects self-qualify. Comparison data is sourced from the same content layer as the services page. Related: US-059, US-066.
