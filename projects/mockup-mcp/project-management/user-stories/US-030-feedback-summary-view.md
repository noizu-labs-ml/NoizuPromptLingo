---
id: US-030
title: "View All Feedback on a Mockup in Summary View"
slug: "feedback-summary-view"
personas: [P-002, P-004, P-005]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "M"
tags: [feedback, summary, overview, dashboard]
---

# US-030: View All Feedback on a Mockup in Summary View

## User Story

**As a** product manager (P-002),
**I want to** see all annotations and feedback for a mockup in a consolidated sidebar or panel,
**So that** I can triage and act on all feedback without clicking through individual pins.

## Acceptance Criteria

- [ ] Given a mockup has annotations, when I open the feedback panel, then all threads are listed with author, timestamp, and status
- [ ] Given the feedback panel is open, when I click a thread item, then the mockup scrolls/zooms to the corresponding pin
- [ ] Given the feedback panel, when I sort by status, then open threads appear before resolved ones
- [ ] Given the feedback summary, when there are no annotations, then an empty state with a call-to-action is displayed

## Notes

Summary view should show counters: total annotations, open, resolved, pinned. This view is the entry point for US-037 (filter) and US-038 (export).
