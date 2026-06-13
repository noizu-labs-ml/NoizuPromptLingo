---
id: US-029
title: "Resolve/Close an Annotation Thread"
slug: "resolve-annotation-thread"
personas: [P-003, P-002]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "S"
tags: [annotations, workflow, resolution, status]
---

# US-029: Resolve/Close an Annotation Thread

## User Story

**As a** UX designer (P-003),
**I want to** mark an annotation thread as resolved,
**So that** the team can track which feedback has been acted upon and reduce visual noise on reviewed mockups.

## Acceptance Criteria

- [ ] Given an open annotation thread, when I click "Resolve", then the thread status changes to resolved and the pin visually dims
- [ ] Given a resolved thread, when I click "Reopen", then the thread returns to open status
- [ ] Given a mockup with mixed annotation statuses, when I toggle "Show resolved", then resolved threads are hidden/shown accordingly
- [ ] Given a thread is resolved, when I view the feedback summary (US-030), then it is counted in the resolved total

## Notes

Only the mockup owner, thread author, or workspace admins should be able to resolve threads. Resolution history should be preserved with timestamp and actor.
