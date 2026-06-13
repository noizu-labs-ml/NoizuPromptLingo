---
id: US-013
title: "Delete a Universe"
slug: "delete-universe"
personas: [P-005, P-006]
epic: "Universe Management"
priority: "should-have"
complexity: "S"
tags: [universe, delete, destructive, safety]
---

# US-013: Delete a Universe

## User Story

**As a** platform admin (P-006),
**I want to** ensure that universe deletion is intentional and irreversible only after explicit confirmation,
**So that** users cannot accidentally destroy months of work and inflate support burden.

## Acceptance Criteria

- [ ] Given I am on Universe Settings, when I click "Delete Universe," then a confirmation dialog appears stating "This will permanently delete all entries, relationships, and generated content. Type the universe name to confirm."
- [ ] Given the confirmation dialog is open, when I type the exact universe name and click "Delete permanently," then the universe and all associated data are soft-deleted and a success toast shows "Universe deleted."
- [ ] Given deletion has occurred, when I navigate to the Dashboard, then the deleted universe no longer appears in my list.
- [ ] Given I am within 30 days of deletion, when I contact support, then an admin (P-006) can restore the universe from the soft-delete record.

## Notes

Hard deletion from storage occurs after 30 days. Only the universe owner can delete; team members cannot. Related: US-010 (settings), US-014 (duplicate — as a safer alternative to accidental deletion scenarios).
