---
id: US-096
title: "Screen Reader Support for Score Visualizations"
slug: "screen-reader-score-visualizations"
personas: [P-001, P-003]
epic: "Accessibility & Performance"
priority: "should-have"
complexity: "M"
tags: [accessibility, screen-reader, a11y, scoring, aria, wcag]
---

# US-096: Screen Reader Support for Score Visualizations

## User Story

**As a** Research Journalist (P-003),
**I want to** access all quality score information through my screen reader,
**So that** I can evaluate source quality without depending on visual charts or progress bars that are inaccessible to me.

## Acceptance Criteria

- [ ] Given a site detail page is loaded, when a screen reader focuses on the composite score display, then the screen reader announces the score as a meaningful value (e.g., "Overall quality score: 87 out of 100")
- [ ] Given the five-dimension score bars are rendered, when a screen reader encounters them, then each dimension is announced with its name and numeric value (e.g., "Originality: 90 out of 100")
- [ ] Given the score history chart (US-081) is displayed, when a screen reader user navigates to it, then a visually-hidden data table is available as an alternative, containing all data points with dates and scores
- [ ] Given the Editor's Pick badge (US-080) is present, when a screen reader focuses on it, then it announces "Editor's Pick: this site scored 90 or above on all quality dimensions" rather than an image with empty alt text
- [ ] Given the anti-slop flag explanation (US-082) is displayed, when a screen reader user navigates to it, then all flag category descriptions are fully readable in logical order

## Notes

Do not use `aria-hidden` on score visualizations without providing a text alternative. SVG-based charts require either `<title>` and `<desc>` elements or an off-screen data table (preferred). Audit with VoiceOver (macOS/iOS) and NVDA (Windows) at minimum. See US-095 for keyboard navigation prerequisites.
