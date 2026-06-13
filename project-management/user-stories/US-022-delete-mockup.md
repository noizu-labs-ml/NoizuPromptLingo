---
id: US-022
title: "Delete a mockup"
slug: "delete-mockup"
personas: [P-001, P-003]
epic: "Mockup Management"
priority: "must-have"
complexity: "S"
tags: [mockup-management, delete, data-management]
---

# US-022: Delete a mockup

## User Story

**As a** UX designer (P-003),
**I want to** delete mockups I no longer need,
**So that** my gallery stays organized and I don't waste storage quota on outdated artifacts.

## Acceptance Criteria

- [ ] Given I click "Delete" on a mockup, when a confirmation dialog appears and I confirm, then the mockup is moved to a soft-delete state and disappears from the gallery immediately
- [ ] Given a soft-deleted mockup, when 30 days have passed, then the artifact and all associated data are permanently purged
- [ ] Given a soft-deleted mockup within the 30-day window, when I navigate to "Recently Deleted", then I can restore it to its original project or permanently delete it immediately
- [ ] Given a mockup is the parent of an iteration chain (US-008), when I attempt to delete it, then I am warned that child mockups reference it and shown the count of children before confirming

## Notes

Deletion of a parent mockup does not cascade-delete children; children retain their `parent_mockup_id` reference which becomes a dangling reference. Storage freed on soft-delete is not credited until permanent deletion. Related to US-008, US-024.
