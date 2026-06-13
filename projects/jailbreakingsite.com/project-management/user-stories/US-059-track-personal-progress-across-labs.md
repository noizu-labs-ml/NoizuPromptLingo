---
id: US-059
title: "Track Personal Progress Across Labs"
slug: "track-personal-progress-across-labs"
personas: [P-008, P-001, P-003]
epic: "Academy — Labs"
priority: "should-have"
complexity: "M"
tags: [academy, progress, dashboard, personal, tracking]
---

# US-059: Track Personal Progress Across Labs

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** track my personal progress across all labs and learning paths in a single dashboard,
**So that** I can see how my skills are developing, what I have completed, and what to tackle next.

## Acceptance Criteria

- [ ] Given I am authenticated and have completed at least one lab, when I visit my Academy progress page, then I see: total labs completed, total points earned, completion breakdown by lab type and difficulty, and active learning path progress bars
- [ ] Given I view my progress dashboard, when I look at the skills coverage section, then I see a heatmap or radar chart showing which catalog technique categories I have covered through lab completions
- [ ] Given I have in-progress labs (launched but not completed), when I view my dashboard, then they appear in an "In Progress" section with a direct "Resume" link
- [ ] Given I completed a lab more than once (replay), when progress is displayed, then my best score is shown with the attempt count and most recent completion date
- [ ] Given I want to see historical activity, when I open the activity log, then I see a chronological list of lab launches, submissions, hints used, and completions

## Notes

The skills coverage heatmap is a high-value visualization that reinforces the Catalog connection — users can see their lab activity mapped to the MITRE-style technique taxonomy, motivating them to cover gaps.
