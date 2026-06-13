---
id: US-028
title: "AI-assisted backlog grooming"
personas: [sarah-kim]
domain: projects
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Eng Lead)**, I want AI to assist with backlog grooming by suggesting priority adjustments, story point estimates, and logical groupings so that grooming sessions are more efficient and consistent.

## Acceptance Criteria

- [ ] Grooming agent analyzes ungroomed backlog items and suggests: priority ranking based on dependencies, business value signals, and aging; story point estimates based on similarity to previously completed items; and logical groupings into epics or themes
- [ ] Suggestions are presented as a side-by-side diff view showing current values vs. agent recommendations, with accept/reject per suggestion
- [ ] Agent flags stale items (no activity for configurable threshold) and suggests archival, splitting, or re-prioritization
- [ ] Estimation suggestions include confidence level and reference items ("similar to US-014 which took 5 points and 3 days")
- [ ] Bulk actions allow accepting all suggestions for a category (e.g., "accept all priority suggestions") with undo capability

## Notes

Grooming is one of the most time-consuming ceremonies. The agent should learn from the team's estimation patterns over time — early suggestions will be rough, but accuracy should improve as the team completes more items. Never auto-apply suggestions; this is always human-confirmed. Consider a "grooming mode" that walks through items one by one with agent commentary.
