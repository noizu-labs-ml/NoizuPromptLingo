---
id: US-087
title: "Admin: Bulk Moderation Actions"
slug: "bulk-moderation-actions"
personas: [P-008]
epic: "Admin & Moderation"
priority: "could-have"
complexity: "M"
tags: [admin, moderation, bulk, efficiency, blogs]
---

# US-087: Admin: Bulk Moderation Actions

## User Story

**As a** platform admin managing a large volume of flagged content (P-008),
**I want to** select multiple blogs or users and apply a moderation action in one operation,
**So that** I can clear moderation backlogs efficiently without repeating the same action for each item.

## Acceptance Criteria

- [ ] Given I am on the admin blog management page, when I check the checkbox next to multiple blogs, then a bulk action toolbar appears at the top of the list showing the count of selected items.
- [ ] Given the bulk action toolbar is visible, when I open the "Action" dropdown, then I see options: Approve All, Flag All (with reason), Remove All.
- [ ] Given I select "Flag All" and choose a reason, when I confirm, then all selected blogs are flagged simultaneously and a success toast shows "X blogs flagged."
- [ ] Given I select "Remove All," when I confirm via a high-friction confirmation dialog (requiring me to type "REMOVE" to proceed), then all selected blogs are soft-deleted in a single batch operation.
- [ ] Given a bulk action is processing, when it takes longer than 1 second, then a progress indicator shows (e.g., "Processing 47 of 120 items...").
- [ ] Given a bulk action partially fails (some items couldn't be processed), when the operation completes, then a summary shows: "85 succeeded, 3 failed" with a list of failed items and reasons.

## Notes

Bulk operations should be processed server-side in a background job for large batches (>50 items) to avoid request timeouts. Maximum bulk selection: 500 items per operation. Relates to US-083, US-084, US-088.
