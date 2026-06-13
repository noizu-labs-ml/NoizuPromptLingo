---
id: US-010
title: "Pin Resources and Feature Threads"
slug: "pinned-content"
personas: [P-003, P-001, P-002]
epic: "Spaces"
priority: "could-have"
complexity: "M"
tags: [spaces, curation, resources]
---

# US-010: Pin Resources and Feature Threads

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** pin important resources and feature key threads in my space,
**So that** new members can quickly find high-value content and understand community priorities.

## Acceptance Criteria

- [ ] Given a space moderator, when they view a resource, then they see a "Pin to Space" button that adds it to the pinned resources section (max 5)
- [ ] Given a space moderator, when they view a thread, then they can toggle "Featured Thread" status (max 3 featured threads)
- [ ] Given a space moderator pins a 6th resource, when they save, then they receive an error to unpin an existing resource first
- [ ] Given a space visitor, when they view the space home page, then they see pinned resources and featured threads in a dedicated section
- [ ] Given a moderator unpins a resource, when the change is saved, then it is removed from the pinned section immediately

## Notes

Depends on US-005 (create space) and US-020 (create resources). Featured threads appear at top of space thread list. Pinned resources display in sidebar.