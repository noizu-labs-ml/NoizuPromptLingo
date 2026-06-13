---
id: US-063
title: "Peer Benchmarking (Pro)"
slug: "peer-benchmarking"
personas: [P-002, P-003]
epic: "Analytics Dashboard"
priority: "should-have"
complexity: "L"
tags: [analytics, benchmarking, pro, peer-comparison, competitive]
---

# US-063: Peer Benchmarking (Pro)

## User Story

**As a** professional tech blogger (P-002),
**I want to** see how my scores compare against other bloggers in my niche,
**So that** I can understand whether I'm genuinely competitive or just improving in a vacuum.

## Acceptance Criteria

- [ ] Given I am a Pro user on /dashboard/analytics, when I view the benchmarking panel, then I see my score for each dimension plotted against the median and top-quartile scores for blogs in my niche
- [ ] Given the benchmark panel renders, when I view a dimension, then I see three reference lines: my score, niche median, and niche top-25%
- [ ] Given my niche has fewer than 10 blogs, when the benchmark panel renders, then it shows "Not enough data in your niche yet" and uses the global median as a fallback
- [ ] Given I am a Free tier user, when I navigate to the analytics page, then the benchmarking panel is visible but blurred with a Pro upgrade prompt overlaid
- [ ] Given the period selector (US-061) is changed, when the benchmark panel updates, then peer median/quartile values recalculate for that period's snapshot

## Notes

Benchmark data is calculated as an aggregate snapshot — individual competitor scores are never exposed. Percentile rank (e.g., "Top 18% in Tech") is the primary value display. This is a primary Pro tier differentiator. See US-061 for period selector, US-060 for radar chart.
