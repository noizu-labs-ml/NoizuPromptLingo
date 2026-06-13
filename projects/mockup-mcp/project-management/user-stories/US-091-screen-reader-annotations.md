---
id: US-091
title: "Screen reader support for mockup annotations"
slug: "screen-reader-annotations"
personas: [P-003, P-007]
epic: "Accessibility & Internationalization"
priority: "should-have"
complexity: "M"
tags: [accessibility, screen-reader, a11y, aria]
---

# US-091: Screen reader support for mockup annotations

## User Story

**As a** QA Engineer (P-007),
**I want to** verify that mockup annotations are fully readable by screen readers,
**So that** users who rely on assistive technology can access all feedback and annotation content.

## Acceptance Criteria

- [ ] Given a mockup has one or more annotations, when a screen reader user navigates to the annotations panel, then each annotation is announced with its author, timestamp, and content in a logical reading order
- [ ] Given an annotation is added in real time by another user, when the update arrives, then a live region announces the new annotation without disrupting the current focus
- [ ] Given an interactive annotation (e.g., one with a reply button), when a screen reader user focuses on it, then the button's purpose is announced via `aria-label` and activating it opens the reply form with focus moved to it

## Notes

Use ARIA live regions (`aria-live="polite"`) for real-time annotation updates. Annotation timestamps should be rendered as `<time datetime="ISO-8601">` elements. Test with VoiceOver (macOS) and NVDA (Windows). Complements US-090 and US-092.
