---
id: US-020
title: "Archive completed items with searchable history"
personas: [raj-patel]
domain: personal
priority: low
mvp_phase: "v0.1"
---

## User Story

As a **Raj Patel (Side-Project Builder)**, I want to archive completed personal items with searchable history so that I can keep my active views clean while still being able to find what I did and when.

## Acceptance Criteria

- [ ] Completed items are automatically moved to an archive after a configurable delay (default: 7 days, options: immediately, 1 day, 7 days, 30 days, never)
- [ ] The archive is full-text searchable with filters for date range, tags, project, and item type
- [ ] Archived items can be restored to active status with a single action, preserving all original metadata
- [ ] The archive view shows completion date, time-to-completion, and original due date for each item
- [ ] Bulk archive and bulk restore actions are available for managing large backlogs

## Notes

The archive serves dual purposes: keeping active views fast and focused, and building a personal accomplishment log. The completion metadata (time-to-completion, on-time vs. late) feeds into the weekly review agent (US-019) and long-term productivity analytics. Storage-wise, archived items are the same entities — archiving is a status transition, not a data migration, which aligns with the scale-free model.
