---
id: US-045
title: "Generation History"
slug: "generation-history"
personas: [P-001, P-003, P-004]
epic: "Generation Engine"
priority: "should-have"
complexity: "M"
tags: [generation, history, audit, draft, traceability]
---

# US-045: Generation History

## User Story

**As a** narrative designer who needs to audit AI contributions to the canon (P-003),
**I want to** view a complete history of all generation requests and their outputs for a universe,
**So that** I can trace the origin of any generated content, revisit discarded drafts, and understand how AI has shaped the world.

## Acceptance Criteria

- [ ] Given I navigate to the Generation History view, when it loads, then I see a reverse-chronological list of all generation events for the current universe, each showing: prompt, type, timestamp, status (promoted/discarded/pending), and token cost.
- [ ] Given I click on a history entry, when the detail view opens, then I see the full generated draft, the sources used, and any edits made before promotion.
- [ ] Given a draft was discarded, when I find it in history, then I can restore it as a new draft for review.
- [ ] Given a draft was promoted to canon, when I view its history entry, then I see a link to the resulting canon entry.
- [ ] Given the history has more than 50 entries, when I view it, then results are paginated with 20 entries per page and include a search/filter by prompt text or date range.

## Notes

Depends on US-036. Generation history data must be stored server-side and retained according to the plan's data retention policy. This is also an input to cost tracking (US-048). Related: US-042 (queue), US-048 (cost).
