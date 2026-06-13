---
id: US-098
title: "Event Output as ARIA-Compatible Announcements"
slug: "aria-event-output"
personas: [P-005]
epic: "Accessibility & Integration"
priority: "should-have"
complexity: "M"
tags: [accessibility, aria, events, screen-reader, a11y, web]
---

# US-098: Event Output as ARIA-Compatible Announcements

## User Story

**As a** blind accessibility game developer (P-005),
**I want to** receive framework events as structured objects that map directly to ARIA live region announcements,
**So that** when I build a web-based game front-end, I can pipe framework events to accessible DOM elements without writing custom serialization or losing semantic information.

## Acceptance Criteria

- [ ] Given `NoizuRPGConfig(event_format="aria")`, when any framework component emits an event, then it is structured as `{"aria_live": "polite|assertive", "aria_atomic": true|false, "text": "...", "event_type": "..."}` rather than a raw string or untyped dict
- [ ] Given an ARIA-formatted event with `aria_live="assertive"`, when a combat hit event fires, then the `text` field contains a complete, self-contained sentence a screen reader can announce without surrounding context (e.g., `"Marcus strikes the goblin for 15 damage. Goblin health: 30 of 80."`)
- [ ] Given an ARIA-formatted event with `aria_live="polite"`, when ambient world description updates, then the announcement is queued politely and does not interrupt an in-progress `assertive` announcement
- [ ] Given a sequence of rapid-fire events (e.g., multi-hit combat round), when ARIA format is enabled, then events with the same `event_type` within 200ms are coalesced into a single announcement to prevent screen reader flooding
- [ ] Given the ARIA event documentation, when a developer reads the "Accessible Web Integration" guide, then a complete React/HTML example is provided showing how to bind the ARIA event stream to `role="log"` and `role="status"` elements

## Notes

The `aria_live` priority mapping should follow WCAG 2.1 guidelines: combat and critical events use `assertive`, ambient and informational events use `polite`. This story complements US-097 (structured text output) which targets screen readers in terminal/CLI contexts; this story targets browser-based web games. Together they form the accessibility foundation for P-005.
