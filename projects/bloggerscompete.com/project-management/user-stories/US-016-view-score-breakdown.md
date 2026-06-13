---
id: US-016
title: "View Score Breakdown"
slug: "view-score-breakdown"
personas: [P-001, P-002, P-003, P-007]
epic: "Blog Indexing & Scoring"
priority: "must-have"
complexity: "M"
tags: [scoring, dashboard, breakdown, radar-chart, dimensions]
---

# US-016: View Score Breakdown

## User Story

**As a** blogger (P-002),
**I want to** see a detailed breakdown of my score across all 6 dimensions,
**So that** I know exactly where my blog excels and where I need to improve.

## Acceptance Criteria

- [ ] Given my blog has been scored, when I visit my blog's Score tab, then I see a radar/spider chart showing all 6 dimension scores plotted simultaneously, plus numeric values for each
- [ ] Given I view the score breakdown, when I hover over or tap a dimension label, then an explanatory tooltip appears describing what that dimension measures in plain language (max 2 sentences)
- [ ] Given I view a specific dimension score, when I click on it, then I see a panel listing 3–5 specific posts that most influenced that dimension's score (positively or negatively) with per-post sub-scores
- [ ] Given my composite score is displayed, when I view the score breakdown, then I also see my percentile rank within my primary niche (e.g., "Top 23% in Lifestyle Blogging")
- [ ] Given I am on the Free tier, when I view the score breakdown, then all 6 dimension scores are visible; AI-generated improvement suggestions (US-020) are shown as locked with a Pro upgrade prompt

## Notes

The radar chart should use accessible colors (WCAG 2.1 AA compliant) with a legend. Scores should be rounded to one decimal place for display. Related: US-015 (scoring), US-019 (score history), US-020 (improvement suggestions).
