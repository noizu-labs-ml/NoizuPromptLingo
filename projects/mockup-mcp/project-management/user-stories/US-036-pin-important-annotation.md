---
id: US-036
title: "Pin Important Annotations"
slug: "pin-important-annotation"
personas: [P-002, P-003]
epic: "Stakeholder Feedback"
priority: "could-have"
complexity: "S"
tags: [annotations, pinning, prioritization, feedback]
---

# US-036: Pin Important Annotations

## User Story

**As a** product manager (P-002),
**I want to** pin high-priority annotations so they are always visible,
**So that** critical feedback is not buried when a mockup has many annotations.

## Acceptance Criteria

- [ ] Given an annotation thread, when I click "Pin", then the annotation is marked as pinned and appears at the top of the feedback summary
- [ ] Given pinned annotations, when I view the mockup, then their pins are rendered with a distinct visual indicator (e.g., star or flag)
- [ ] Given multiple pinned annotations, when I view the summary panel, then they are grouped in a "Pinned" section above regular annotations
- [ ] Given a pinned annotation, when I click "Unpin", then it returns to its natural sort order

## Notes

Only mockup owners and workspace admins should be able to pin annotations. Pinned count should appear in the mockup card on the dashboard.
