---
id: US-076
title: "View Detailed Score Breakdown on Site Detail Page"
slug: "score-breakdown-detail"
personas: [P-001, P-003, P-004]
epic: "Quality Scoring Engine"
priority: "must-have"
complexity: "M"
tags: [scoring, site-detail, transparency, ux]
---

# US-076: View Detailed Score Breakdown on Site Detail Page

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** see a breakdown of how a site scored across all five quality dimensions,
**So that** I can understand exactly why a site was rated highly and decide if it matches what I'm looking for.

## Acceptance Criteria

- [ ] Given I am viewing a site detail page, when the page loads, then I see five individual dimension scores (originality, depth, freshness, human authorship, design quality) displayed alongside the composite score
- [ ] Given the score breakdown is visible, when I hover or tap on a dimension label, then a tooltip explains what that dimension measures in plain language
- [ ] Given a site has a low score in one dimension, when I view the breakdown, then the low-scoring dimension is visually distinguished (e.g., muted color, lower bar fill) so I can identify the weakness at a glance
- [ ] Given the scores are displayed, when I view the page on mobile, then all five dimension scores remain legible without horizontal scrolling

## Notes

The five-dimension breakdown is the core trust signal for P-003 (Research Journalist) who needs to assess source quality. Scores should be presented as labeled progress bars or a radar chart. See US-077 for the methodology explanation page that provides deeper context for these numbers.
