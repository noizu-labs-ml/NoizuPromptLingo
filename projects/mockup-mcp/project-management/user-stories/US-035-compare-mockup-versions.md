---
id: US-035
title: "Compare Two Mockup Versions Side-by-Side"
slug: "compare-mockup-versions"
personas: [P-003, P-002, P-005]
epic: "Stakeholder Feedback"
priority: "should-have"
complexity: "L"
tags: [versioning, comparison, diff, review]
---

# US-035: Compare Two Mockup Versions Side-by-Side

## User Story

**As a** UX designer (P-003),
**I want to** compare two versions of a mockup side-by-side,
**So that** I can clearly communicate design changes to stakeholders during review sessions.

## Acceptance Criteria

- [ ] Given a mockup with multiple versions, when I select two versions and click "Compare", then both are displayed in a synchronized split-pane view
- [ ] Given the split-pane view, when I scroll one panel, then the other panel scrolls in sync
- [ ] Given two versions in comparison, when visual differences exist, then changed regions are highlighted with an overlay
- [ ] Given the comparison view, when I click a highlighted diff region, then I can add an annotation scoped to that version

## Notes

For SVG/diagram mockups, structural diff (added/removed nodes) should be computed and visualized. For image mockups, pixel-diff overlay is sufficient. Version selection UI should surface version metadata (timestamp, author, label).
