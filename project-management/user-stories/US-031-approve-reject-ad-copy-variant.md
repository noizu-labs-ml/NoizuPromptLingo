---
id: US-031
title: "Approve or Reject a Generated Ad Copy Variant"
slug: "approve-reject-ad-copy-variant"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "must-have"
complexity: "S"
tags: [ad-copy, approval-workflow, campaigns]
---

# US-031: Approve or Reject a Generated Ad Copy Variant

## User Story

**As the** Growth Operator (P-005),
**I want to** approve or reject each generated ad copy variant individually,
**So that** only messaging I've vetted is eligible to be used or published under the ad group.

## Acceptance Criteria

- [ ] Given an ad copy variant in "pending review" status, when I select "approve", then its status changes to "approved" and it becomes eligible for downstream use.
- [ ] Given an ad copy variant in "pending review" status, when I select "reject" and optionally supply a reason, then its status changes to "rejected" and it is excluded from active-use selection lists.
- [ ] Given an ad group's copy list contains a mix of pending, approved, and rejected variants, when I view the list, then each variant's status is visually distinguished and filterable.

## Notes

Mirrors the generic accept/reject step of the creative-asset pipeline in US-036. Builds on generation from US-030.
