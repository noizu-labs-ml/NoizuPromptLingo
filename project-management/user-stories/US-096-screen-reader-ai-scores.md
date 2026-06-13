---
id: US-096
title: "Screen Reader Support for AI Scores"
slug: "screen-reader-ai-scores"
personas: [P-001, P-006]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "M"
tags: [accessibility, screen-reader, AI-scores, ARIA, WCAG, a11y]
---

# US-096: Screen Reader Support for AI Scores

## User Story

**As a** visually impaired blogger using a screen reader (P-001),
**I want to** hear meaningful descriptions of my AI score results and score breakdowns,
**So that** I have full access to my performance data without needing to see the visual charts.

## Acceptance Criteria

- [ ] Given the AI score radar chart or spider chart is rendered, when a screen reader encounters it, then the chart element has `role="img"` and an `aria-label` that fully describes the scores (e.g., "AI Score radar chart: Originality 82, Engagement 75, Consistency 90, Writing Quality 88, SEO 71, Visual Design 79. Overall score: 81").
- [ ] Given the score dimension bars (progress bars), when a screen reader focuses on one, then it reads the dimension name, numeric score, and a text interpretation (e.g., "Originality: 82 out of 100 — Excellent").
- [ ] Given a score trend indicator (up/down arrow icon), when a screen reader encounters the icon, then it has an `aria-label` describing the change (e.g., "Trending up: score increased by 4 points since last month").
- [ ] Given animated score count-up on page load, when a screen reader is active, then the final numeric value is announced once (not each intermediate value during animation), using `aria-live="polite"`.
- [ ] Given the score breakdown table (alternative to chart), when it is rendered, then all cells have appropriate `<th>` headers and the table has a `<caption>` reading "AI Score Breakdown for {Blog Name}."
- [ ] Given the platform is tested with NVDA + Firefox and VoiceOver + Safari, when all score UI components are navigated, then all information is conveyed without requiring visual perception of any component.

## Notes

Visual charts must always have a text-based alternative (data table or `aria-label`). Do not rely on color alone to convey score quality (also provide text labels: Poor/Fair/Good/Excellent). Score interpretation labels: 0-40 Needs Work, 41-60 Fair, 61-80 Good, 81-100 Excellent. Relates to US-095, US-097.
