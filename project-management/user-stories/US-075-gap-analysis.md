---
id: US-075
title: "Gap Analysis — What's Missing"
slug: "gap-analysis"
personas: [P-001, P-003, P-004, P-005]
epic: "Search & Discovery"
priority: "won't-have-yet"
complexity: "XL"
tags: [search, discovery, gap-analysis, ai, completeness, worldbuilding]
---

# US-075: Gap Analysis — What's Missing

## User Story

**As a** fiction podcaster (P-004),
**I want to** receive an AI analysis of what major worldbuilding areas are underdeveloped or absent from my universe,
**So that** I can direct my creative energy toward the gaps that would most improve my world's coherence and richness.

## Acceptance Criteria

- [ ] Given a universe has at least 20 entries, when I trigger a Gap Analysis from the Universe Explorer, then the system produces a structured report identifying entry types that are sparse relative to the universe's apparent scope (e.g., "you have 40 characters but only 2 factions — consider expanding factions").
- [ ] Given the gap analysis report is generated, when I view it, then each identified gap includes a plain-language explanation, the count of existing entries of that type, and a suggested minimum for a universe of my scope.
- [ ] Given a gap is identified, when I click "Generate Entry for This Gap," then the Generation Studio (or Canon Editor) opens pre-seeded with a prompt scaffold based on the gap type and the universe's existing thematic context.
- [ ] Given a universe has a well-developed area, when the gap analysis runs, then that area is acknowledged in a "Strengths" section so the report is not purely deficit-focused.

## Notes

Won't-have-yet because it requires mature semantic analysis and threshold calibration that depends on a significant corpus of real-universe data to tune well. Depends on US-070 (semantic search), US-069 (full-text search). Related: US-074 (suggested connections). Revisit post-beta once usage data informs gap thresholds.
