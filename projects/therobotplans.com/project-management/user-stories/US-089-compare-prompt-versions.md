---
id: US-089
title: "Compare prompt versions side-by-side with performance delta"
personas: [lin-zhao]
domain: prompt-archival
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to compare two prompt versions side-by-side with highlighted diffs and performance deltas so that I can make data-driven decisions about which prompt configurations produce better agent behavior.

## Acceptance Criteria

- [ ] A side-by-side comparison view shows two selected prompt versions with inline diff highlighting (additions in green, deletions in red, modifications in yellow)
- [ ] Performance metrics from the agent-eval domain are displayed alongside each version: average quality score, task completion rate, escalation frequency, and cost per task
- [ ] The comparison view supports selecting any two versions — not just consecutive ones — across the same agent or across different agents with the same role
- [ ] A summary panel auto-generates a plain-language description of the key differences and their likely behavioral impact
- [ ] The comparison can be exported as a shareable report (Markdown or PDF) for team review

## Notes

This bridges prompt-archival and agent-eval into a single analytical workflow. The performance delta is what makes this more than a text diff tool — it answers "did this change actually improve things?" Cross-agent comparison (e.g., comparing the code review prompt on Team A vs Team B) enables organizational learning. The auto-generated summary should use the platform's own AI capabilities, creating a meta-layer where agents help humans understand agent configuration. Edge case: comparing prompts where the eval methodology itself changed between versions — the delta display should flag this.
