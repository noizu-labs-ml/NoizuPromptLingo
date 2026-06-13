---
id: US-027
title: "Add Inline Comment/Annotation on a Mockup"
slug: "add-inline-annotation"
personas: [P-003, P-002, P-005]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "M"
tags: [annotations, feedback, comments, inline]
---

# US-027: Add Inline Comment/Annotation on a Mockup

## User Story

**As a** UX designer (P-003),
**I want to** click on a specific area of a mockup and leave an inline annotation,
**So that** feedback is precisely anchored to the element being discussed.

## Acceptance Criteria

- [ ] Given a mockup is open, when I click on any region, then a comment pin is placed at that coordinate and a text input appears
- [ ] Given I submit an annotation, when the page reloads, then the pin and comment are persisted at the correct position
- [ ] Given a mockup with annotations, when I hover over a pin, then the comment preview appears without navigating away
- [ ] Given a mockup is viewed at different zoom levels, when annotations are present, then pins remain anchored to their correct visual positions

## Notes

Coordinate storage should be normalized (percentage-based) so annotations survive image resizing. Pins should be visually distinct by status (open, resolved). Relates to US-029 (resolve) and US-036 (pin).
