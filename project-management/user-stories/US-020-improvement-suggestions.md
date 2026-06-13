---
id: US-020
title: "AI Improvement Suggestions"
slug: "improvement-suggestions"
personas: [P-001, P-002, P-004, P-007]
epic: "Blog Indexing & Scoring"
priority: "should-have"
complexity: "L"
tags: [ai, suggestions, scoring, improvement, pro]
---

# US-020: AI Improvement Suggestions

## User Story

**As a** blogger (P-001),
**I want to** receive AI-generated, actionable suggestions for improving each score dimension,
**So that** I know specifically what to change to raise my scores and compete more effectively.

## Acceptance Criteria

- [ ] Given my blog has been scored, when I view the Score Breakdown (US-016), then each dimension shows an "Improve" button (locked on Free tier, accessible on Pro/Team)
- [ ] Given I am on Pro and click "Improve" on a dimension, when the suggestions load, then I see 3–5 specific, actionable recommendations for that dimension tied to evidence from my actual posts (e.g., "Your last 5 posts averaged 187 words — aim for 600+ for better Writing Quality scores")
- [ ] Given suggestions are displayed, when I review them, then each suggestion includes: the issue identified, the impact on score (High/Medium/Low), and a concrete next step with an example
- [ ] Given I complete an action from the suggestions list, when I manually mark it as done, then it is moved to a "Completed improvements" section and tracked against score changes from the next re-index
- [ ] Given I dismiss a suggestion, when I click "Not relevant", then it is hidden from the active list and I can restore dismissed suggestions from a "Dismissed" tab

## Notes

Suggestions should be generated at score time (not on-demand) to avoid LLM latency on page load — cache and serve from the score record. Free tier users should see a preview of 1 suggestion per dimension (blurred) with a CTA to upgrade. Related: US-015 (scoring), US-016 (score breakdown), US-018 (re-index to measure improvement impact).
