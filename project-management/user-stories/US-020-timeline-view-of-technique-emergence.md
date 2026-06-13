---
id: US-020
title: "Timeline View of Technique Emergence"
slug: "timeline-view-of-technique-emergence"
personas: [P-004, P-001, P-006]
epic: "Attack Catalog"
priority: "could-have"
complexity: "M"
tags: [catalog, timeline, history, research, trends]
---

# US-020: Timeline View of Technique Emergence

## User Story

**As a** researcher or red team lead tracking the evolution of LLM attacks over time (P-004, P-001, P-006),
**I want to** view a chronological timeline of when techniques were first discovered and published,
**So that** I can understand the historical trajectory of jailbreak research and identify emerging threat trends.

## Acceptance Criteria

- [ ] Given I navigate to the catalog timeline view, when the page loads, then techniques are plotted on a horizontal time axis by first-seen date, grouped by quarter or month
- [ ] Given I hover over a technique point on the timeline, when the tooltip appears, then it shows technique name, taxonomy category, severity, and a link to the detail page
- [ ] Given I filter by model family or severity (US-013, US-014), when the timeline refreshes, then only techniques matching those filters are rendered
- [ ] Given the timeline spans multiple years, when I interact with the zoom controls, then I can zoom into a specific time range to see dense periods more clearly

## Notes

First-seen date is based on earliest public disclosure or documented use, not catalog entry date. The timeline view is a discovery and trend-analysis tool most relevant to researchers (P-004) and red team leads (P-001). Dependent on having a sufficiently populated catalog at launch.
