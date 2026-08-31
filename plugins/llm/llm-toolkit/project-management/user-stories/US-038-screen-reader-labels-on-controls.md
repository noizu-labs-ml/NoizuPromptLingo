---
id: US-038
title: "Screen-reader labels on controls"
slug: screen-reader-labels-on-controls
personas: [P-007]
epic: "Accessibility & i18n"
priority: should-have
complexity: medium
tags: [accessibility, screen-reader, web]
---

# US-038: Screen-Reader Labels on Controls

## User Story

**As a** novice occasional user
**I want to** have search filters, mode toggles, and thread action buttons carry descriptive ARIA labels
**So that** if I'm using assistive technology, or just want the browser's built-in accessibility tooling to help me understand a control, each element announces meaningful purpose rather than an unlabeled icon

## Acceptance Criteria

- **Given** the search bar's keyword/semantic mode toggle (from US-026)
  **When** inspected via accessibility tooling
  **Then** it exposes an ARIA label describing the current mode and what activating the other option does (e.g. "Switch to semantic search")

- **Given** icon-only buttons in the thread viewer (e.g. collapse/expand toggles, Resume, archive)
  **When** inspected
  **Then** each carries an `aria-label` describing its action and, where applicable, its current state (e.g. "Expand tool call result", "Resume this conversation")

- **Given** search result filters (project, role, date range from US-023/024/025)
  **When** inspected
  **Then** each filter control and its current selected value(s) are announced, not just a bare checkbox/select with no accessible name

## Notes
Directly serves Jamie, whose comfort with the tool depends on self-explanatory UI; proper ARIA labeling also benefits anyone using screen readers regardless of persona. Should-have, layered on top of the keyboard-navigation baseline in US-037.
