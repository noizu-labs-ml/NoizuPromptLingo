---
id: US-030
title: "Project Activity Feed"
slug: "project-activity-feed"
personas: [P-007, P-002]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "M"
tags: [dashboard, activity, feed, updates]
---

# US-030: Project Activity Feed

## User Story

**As an** active client who checks in periodically (P-007),
**I want to** see a chronological feed of project activity — status changes, milestone completions, new deliverables, messages — within a project,
**So that** I can catch up on what happened since my last visit without reading through email threads.

## Acceptance Criteria

- [ ] Given I am on a project detail page, when I view the Activity tab, then I see a reverse-chronological list of activity events with timestamps
- [ ] Given a milestone is marked complete by Keith, when I next view the feed, then the completion event appears as an activity item
- [ ] Given a new deliverable is uploaded, when I view the feed, then an activity item appears with a link to the deliverable
- [ ] Given a support ticket is updated, when I view the project feed, then the ticket update appears as a linked activity item
- [ ] Given the feed has more than 20 items, when I scroll to the bottom, then older items load via pagination or infinite scroll
- [ ] Given I want to filter the feed, when I select a filter (e.g. "milestones only"), then only matching event types are shown

## Notes

Activity items are system-generated from state changes — not manually authored. Event types: milestone updated, deliverable uploaded, status changed, message received, ticket opened/resolved, meeting scheduled. Consider a cross-project activity feed on the main dashboard (US-026) showing the 10 most recent events across all projects.
