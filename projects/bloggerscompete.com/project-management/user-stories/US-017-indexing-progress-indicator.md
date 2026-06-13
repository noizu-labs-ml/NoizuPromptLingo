---
id: US-017
title: "Indexing Progress Indicator"
slug: "indexing-progress-indicator"
personas: [P-001, P-004]
epic: "Blog Indexing & Scoring"
priority: "should-have"
complexity: "S"
tags: [indexing, ux, progress, status, dashboard]
---

# US-017: Indexing Progress Indicator

## User Story

**As a** new blogger (P-004),
**I want to** see the progress of my blog's indexing and scoring in real time,
**So that** I'm not left wondering whether the system is working after I submit my URL.

## Acceptance Criteria

- [ ] Given my blog URL has been submitted and indexing has started, when I view my dashboard, then I see a progress card showing the current stage: "Detecting Platform" → "Discovering Feed" → "Crawling Posts" → "Running AI Scoring" → "Complete"
- [ ] Given the progress card is visible, when a stage completes, then the card updates in real time (via WebSocket or polling every 10 seconds) without requiring a page refresh
- [ ] Given the indexing job is in the "Crawling Posts" stage, when progress updates, then I see a posts counter (e.g., "Indexed 12 of ~40 posts")
- [ ] Given indexing fails at any stage, when the error occurs, then the progress card shows the failed stage highlighted in red with a human-readable error message and a "Retry" button
- [ ] Given indexing completes successfully, when all stages are marked done, then the progress card transitions to the score breakdown view (US-016) with a brief success animation

## Notes

For blogs that complete indexing in under 60 seconds, the progress card should still animate through all stages (minimum 500ms per stage) to avoid a disorienting instant transition. Related: US-011 (submission), US-015 (scoring), US-016 (score breakdown).
